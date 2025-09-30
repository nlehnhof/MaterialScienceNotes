using CSV
using DataFrames
using Plots

function save_png_plot(df::DataFrame, xcol::Symbol, ycol::Symbol, filename::String;
                       color::Symbol=:blue, yield_stress::Union{Nothing,Float64}=nothing,
                       yield_strain_target::Union{Nothing,Float64}=nothing)

    # Convert stress to MPa
    ydata = df[!, ycol] ./ 1e6
    xdata = df[!, xcol]

    # === Ultimate stress ===
    ultimate_index = argmax(ydata)
    ultimate_strain, ultimate_stress = xdata[ultimate_index], ydata[ultimate_index]

    # === Scatter plot stress-strain curve ===
    plt = scatter(
        xdata, ydata,
        xlabel = "Strain",
        ylabel = "Stress (MPa)",
        marker = (:circle, 2),
        legend = :bottomright,
        seriescolor = color,      # sets both line + marker color
        markerstrokecolor = :auto, # outline matches fill
        markercolor = color,       # force fill color
        label = false,
    )

    # === Plot yield stress if given ===
    if yield_stress !== nothing
        if yield_strain_target !== nothing
            # find point closest to target strain
            idx_yield = argmin(abs.(xdata .- yield_strain_target))
        else
            # restrict to data up to ultimate stress
            ydata_sub = ydata[1:ultimate_index]
            xdata_sub = xdata[1:ultimate_index]
            # find point closest to target stress
            idx_yield = argmin(abs.(ydata_sub .- yield_stress))
        end

        yield_strain, yield_stress_actual = xdata[idx_yield], ydata[idx_yield]

        scatter!([yield_strain], [yield_stress_actual],
                 color=:green, marker=:circle, ms=6, label="Yield Stress")
    end

    # === Plot ultimate stress ===
    scatter!([ultimate_strain], [ultimate_stress],
             color=:orange, marker=:circle, ms=6, label="Ultimate Stress")

    # === Save ===
    savefig(plt, filename * ".png")
    println("✅ Saved plot to $(filename).png")
end

# === Load CSVs ===
df_al = CSV.read("lab1aluminum.csv", DataFrame; normalizenames=true)
df_steel = CSV.read("lab1steel.csv", DataFrame; normalizenames=true)

# === Save PNGs with known yield stresses ===
save_png_plot(df_al, :strain, :stress, "aluminum_plot", color=:red, yield_stress=305.0)
save_png_plot(df_steel, :strain, :stress, "steel_plot", color=:blue,
              yield_stress=390.0, yield_strain_target=0.0125)
