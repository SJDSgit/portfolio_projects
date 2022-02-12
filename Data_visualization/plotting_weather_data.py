from bokeh.core.property.numeric import Size
from bokeh.models import tools
import pandas
from bokeh.plotting import show,figure,output_file

df=pandas.read_excel("https://github.com/pythonizing/data/raw/master/verlegenhuken.xlsx")
df["Temperature"]=df["Temperature"]/10
df["Pressure"]=df["Pressure"]/10

p=figure(plot_width=500,plot_height=400,tools='pan')

p.title.text="Temperature and Air Pressure"
p.title.text_color="Violet"
p.title.text_font="times roman"
p.title.text_font_style="bold" and "italic"
p.xaxis.minor_tick_line_color="Indigo"
p.yaxis.minor_tick_line_color="blue"
p.xaxis.axis_label="Temperature (°C)"
p.yaxis.axis_label="Pressure (hPa)"

p.circle(df["Temperature"],df['Pressure'],size=.5)
output_file("Weather.html")
show(p)