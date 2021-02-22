
% This is used while debugging the color sorting
% heuristics.
% I uncomment a line in find.c++ to output the hues, converted
% into radians, and with zeros between them.
% Then I feed those numbers into Octave like this
c4=[2.97465, 0, 3.76425, 0, 3.76991, 0, 2.97269, 0, 6.05231, 0, 6.06183, 0]
polar(c4, c4>0, 'r'); set(gca, "linewidth", 0.01)
% ... which creates one red line per marker, from plot's center out to marker's hue
% along a unit circle
