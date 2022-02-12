from bokeh.plotting import figure
from bokeh.io import show, output_file

x=[1,2,3,4,5,6]
y=[7,8,9,10,11,12]

output_file("line_graph.html") # preparing a output file.

f=figure() # creating a figure object.

f.line(x,y) # replace line with other e.g. circle or triangle for other glyphs.

show(f) # display the object (graph).