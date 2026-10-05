using System.Text;

using ECommerceBackend.Data;
using ECommerceBackend.Helpers;
using ECommerceBackend.Models;
using ECommerceBackend.Repositories;
using ECommerceBackend.Repositories.Interfaces;
using ECommerceBackend.Services;
using ECommerceBackend.Services.Interfaces;
using ECommerceBackend.Logging;
using ECommerceBackend.Middleware;
using ECommerceBackend.Email;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();

builder.Services.Configure<LoggingSettings>(builder.Configuration.GetSection("LoggingSettings"));
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));

var loggingProvider = builder.Configuration.GetSection("LoggingSettings").GetValue<string>("Provider");

if (string.Equals(loggingProvider, "Database", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddScoped<IApplicationLogger, DatabaseLogger>();
}
else if (string.Equals(loggingProvider, "File", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddSingleton<IApplicationLogger, FileLogger>();
}
else if (string.Equals(loggingProvider, "Both", StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddScoped<DatabaseLogger>();
    builder.Services.AddSingleton<FileLogger>();
    builder.Services.AddScoped<IApplicationLogger, CombinedLogger>();
}

builder.Services.AddControllers();

builder.Services.AddCors(options =>
{
    options.AddPolicy("ReactPolicy", policy =>
    {
        policy
            .WithOrigins(
                "http://localhost:5173",
                "http://ashik.test")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException("DefaultConnection is missing. Check appsettings.json.");
}

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));
});

var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection["Key"];
var jwtIssuer = jwtSection["Issuer"];
var jwtAudience = jwtSection["Audience"];

Console.WriteLine("================================");
Console.WriteLine("JWT CONFIGURATION");
Console.WriteLine("================================");
Console.WriteLine($"JWT Key exists: {!string.IsNullOrWhiteSpace(jwtKey)}");
Console.WriteLine($"JWT Issuer: {jwtIssuer}");
Console.WriteLine($"JWT Audience: {jwtAudience}");
Console.WriteLine("================================");

if (string.IsNullOrWhiteSpace(jwtKey))
    throw new InvalidOperationException("JWT Key is missing. Check appsettings.json and appsettings.Development.json.");
if (string.IsNullOrWhiteSpace(jwtIssuer))
    throw new InvalidOperationException("JWT Issuer is missing. Check appsettings.json and appsettings.Development.json.");
if (string.IsNullOrWhiteSpace(jwtAudience))
    throw new InvalidOperationException("JWT Audience is missing. Check appsettings.json and appsettings.Development.json.");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IWishlistRepository, WishlistRepository>();
builder.Services.AddScoped<IWishlistService, WishlistService>();
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<ICartRepository, CartRepository>();
builder.Services.AddScoped<ICartService, CartService>();
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IEmailNotificationService, EmailNotificationService>();
builder.Services.AddScoped<IFakePaymentService, FakePaymentService>();
builder.Services.AddScoped<PasswordHelper>();
builder.Services.AddScoped<JwtHelper>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter your JWT token."
    });

    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});

var app = builder.Build();

try
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();

    Console.WriteLine("Checking database...");
    await dbContext.Database.MigrateAsync();
    Console.WriteLine("Database migration completed.");

    const string adminEmail = "admin@ecommerce.com";
    const string adminPassword = "Admin@123";

    var adminExists = await dbContext.Users.AnyAsync(u => u.Email == adminEmail);

    if (!adminExists)
    {
        var passwordHelper = scope.ServiceProvider.GetRequiredService<PasswordHelper>();
        var admin = new User
        {
            Name = "Admin",
            Email = adminEmail,
            PasswordHash = passwordHelper.HashPassword(adminPassword),
            Role = "Admin"
        };

        dbContext.Users.Add(admin);
        await dbContext.SaveChangesAsync();
        Console.WriteLine("Default admin user created.");
    }
    else
    {
        Console.WriteLine("Admin user already exists.");
    }
}
catch (Exception ex)
{
    Console.WriteLine("================================");
    Console.WriteLine("DATABASE STARTUP ERROR");
    Console.WriteLine("================================");
    Console.WriteLine(ex.Message);
    Console.WriteLine("================================");
    throw;
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("ReactPolicy");
app.UseMiddleware<CustomRequestLoggingMiddleware>();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();