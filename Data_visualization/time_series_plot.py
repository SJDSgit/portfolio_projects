from bokeh.core.enums import SizingMode
from bokeh.plotting import figure, show, output_file
import pandas

df=pandas.read_csv("adbe.csv", parse_dates=["Date"])

p=figure(width=500,height=250, x_axis_type="datetime",sizing_mode="scale_both")

p.line(df["Date"], df["Close"], color="green", alpha=.5)

output_file("Time_series_plot.html")

show(p)