using CSV
using DataFrames
using Plots

function save_png_plot(df::DataFrame, xcol::Symbol, ycol::Symbol, filename::String; color::Symbol=:blue)
    # Convert stress to MPa (assuming stress is in Pascals)
    ydata = df[!, ycol] ./ 1e6
    xdata = df[!, xcol]

    plt = plot(
        xdata, ydata,
        xlabel = "Strain",
        ylabel = "Stress (MPa)",
        lw = 2,
        legend = false,
        color = color,
        # marker = :circle
    )

    # Save PNG
    savefig(plt, filename * ".png")
    println("✅ Saved plot to $(filename).png")
end

# === Load CSVs (header line is used automatically) ===
df_al = CSV.read("lab1aluminum.csv", DataFrame; normalizenames=true)
df_steel = CSV.read("lab1steel.csv", DataFrame; normalizenames=true)

# === Save PNGs ===
save_png_plot(df_al, :strain, :stress, "aluminum_plot", color=:red)
save_png_plot(df_steel, :strain, :stress, "steel_plot", color=:blue)
