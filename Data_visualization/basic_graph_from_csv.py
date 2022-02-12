from bokeh.plotting import figure
from bokeh.io import show, output_file
import pandas

df=pandas.read_csv("data.csv")
x=df["x"]
y=df["y"]

output_file("line_graph_from_csv.html")

f=figure()

f.line(x,y)

show(f)