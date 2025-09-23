using CSV
using DataFrames
using Statistics
using Plots

# --- 1. Load data ---
file1 = "lab1aluminum.csv"
file2 = "lab1steel.csv"
df = CSV.read(file2, DataFrame)

strain = df.strain                # already normalized in your CSV
stress = df.stress ./ 1_000_000  # convert from N/mm^2 (Pa) to MPa

# --- 2. Plot stress vs strain ---
plt = plot(strain, stress,
    xlabel="Strain",
    ylabel="Stress (MPa)",
    lw=2,
    legend=false,
    title="Aluminum Stress-Strain Curve"
)

# --- 3. Compute approximate modulus of elasticity ---
# Using first N points in linear region
N = 10
modulus = mean([(stress[i+15] - stress[i]) / (strain[i+15] - strain[i]) for i in 1:50])
println("Estimated Modulus of Elasticity ≈ $(modulus) MPa")

# --- 4. Compute 0.2% offset yield stress ---
offset = 0.002  # 0.2% strain
offset_line = modulus .* (strain .- offset)

# Find closest point between stress and offset line
idx_yield = argmin(abs.(stress .- offset_line))
yield_stress = stress[idx_yield]
yield_strain = strain[idx_yield]

println("Estimated Yield Stress ≈ $(yield_stress) MPa at strain = $(yield_strain)")

# Mark yield point on plot
scatter!(plt, [yield_strain], [yield_stress], color=:red, label="Yield point")

plot!(plt, strain[1:1000], strain[1:1000] * modulus)
display(plt)

# --- 5. Compute ultimate tensile strength ---
ultimate_tensile = maximum(stress)
idx_uts = argmax(stress)
ultimate_strain = strain[idx_uts]

println("Ultimate Tensile Strength ≈ $(ultimate_tensile) MPa at strain = $(ultimate_strain)")

# Mark ultimate tensile point on plot
scatter!(plt, [ultimate_strain], [ultimate_tensile], color=:blue, label="UTS point")

# --- 6. Show plot with points ---
display(plt)
