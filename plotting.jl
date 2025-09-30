using CSV
using DataFrames
using Plots

"""
    save_combined_plot(dfs, xcol, ycol, filename; colors, yield_stresses, yield_strain_targets)

Plots multiple stress–strain datasets on the same graph with yield and ultimate stress points.
- `dfs`: Dict mapping material name => DataFrame
- `xcol`, `ycol`: Symbols for strain and stress column names
- `filename`: output file name (without extension)
- `colors`: Dict mapping material name => color
- `yield_stresses`: Dict mapping material name => yield stress (MPa), or nothing
- `yield_strain_targets`: Dict mapping material name => target strain for yield point lookup (optional)
"""
function save_combined_plot(
    dfs::Dict{String,DataFrame}, xcol::Symbol, ycol::Symbol, filename::String;
    colors::Dict{String,Symbol},
    yield_stresses::Dict{String,<:Union{Nothing,Float64}}=Dict(),
    yield_strain_targets::Dict{String,<:Union{Nothing,Float64}}=Dict()
)

    plt = plot(
        xlabel = "Strain",
        ylabel = "Stress (MPa)",
        legend = :bottomright,
    )

    for (label, df) in dfs
        color = colors[label]
        ydata = df[!, ycol] ./ 1e6  # convert Pa → MPa
        xdata = df[!, xcol]

        # === Ultimate stress ===
        ultimate_index = argmax(ydata)
        ultimate_strain, ultimate_stress = xdata[ultimate_index], ydata[ultimate_index]

        # === Curve ===
        plot!(plt, xdata, ydata, color=color, label=label)

        # === Yield stress if available ===
        if haskey(yield_stresses, label) && yield_stresses[label] !== nothing
            ys = yield_stresses[label]
            if haskey(yield_strain_targets, label) && yield_strain_targets[label] !== nothing
                idx_yield = argmin(abs.(xdata .- yield_strain_targets[label]))
            else
                ydata_sub = ydata[1:ultimate_index]
                xdata_sub = xdata[1:ultimate_index]
                idx_yield = argmin(abs.(ydata_sub .- ys))
            end

            yield_strain, yield_stress_actual = xdata[idx_yield], ydata[idx_yield]

            # Point
            scatter!(plt, [yield_strain], [yield_stress_actual],
                     color=:green, marker=:circle, ms=6,
                     label="Yield ($label): $(round(yield_stress_actual, digits=1)) MPa @ $(round(yield_strain, digits=4))")

            # Tag line
            plot!(plt, [yield_strain, yield_strain], [0, yield_stress_actual],
                  linestyle=:dash, color=:green, label=false)
        end

        # === Ultimate stress point + tag line ===
        scatter!(plt, [ultimate_strain], [ultimate_stress],
                 color=:orange, marker=:circle, ms=6,
                 label="Ultimate ($label): $(round(ultimate_stress, digits=1)) MPa @ $(round(ultimate_strain, digits=4))")

        plot!(plt, [ultimate_strain, ultimate_strain], [0, ultimate_stress],
              linestyle=:dash, color=:orange, label=false)
    end

    savefig(plt, filename * ".png")
    println("✅ Saved combined plot to $(filename).png")
end

# === Example usage ===
if abspath(PROGRAM_FILE) == @__FILE__
    df_al = CSV.read("lab1aluminum.csv", DataFrame; normalizenames=true)
    df_steel = CSV.read("lab1steel.csv", DataFrame; normalizenames=true)

    save_combined_plot(
        Dict("Aluminum" => df_al, "Steel" => df_steel),
        :strain, :stress, "combined_plot";
        colors=Dict("Aluminum"=>:red, "Steel"=>:blue),
        yield_stresses=Dict("Aluminum"=>305.0, "Steel"=>390.0),
        yield_strain_targets=Dict("Steel"=>0.0125)
    )
end
