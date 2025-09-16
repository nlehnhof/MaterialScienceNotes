using CSV
using DataFrames
using PGFPlotsX
using Plots

file1 = "lab1aluminum.csv"
file2 = "lab1steel.csv"

# Read CSV
df = CSV.read(file1, DataFrame)

plt = plot(df.strain, df.stress ./ 1000,
    xlabel = "Strain",
    ylabel="Stress (MPa)",
    title="Stress-Strain Curve for 6061 Aluminum",
    lw=2,
    legend = false)

display(plt) 

dfsteel = CSV.read(file2, DataFrame)

pltsteel = plot(dfsteel.strain, dfsteel.stress ./ 1000,
    xlabel = "Strain",
    ylabel="Stress (MPa)",
    title="Stress-Strain Curve for 1080 Steel (cold worked)",
    lw=2,
    legend = false)

display(pltsteel)

# # Example: plot column :x vs :y
# @pgf Axis(
#     {
#         xlabel = "Strain",
#         ylabel = "Stress (MPa)",
#         title  = "Stress-Strain for Steel 1018 (cold rolled)",
#         width  = "10cm",
#         height = "7cm",
#     },
#     Plot(
#         {
#             color = "blue",
#             mark  = "o",
#         },
#         Table(x=df.x, y=df.y)
#     )
# ) |> save("plot.tex")
