function r = find_nearest_note(f) 

r = 2^((round(12*log2(f/440)+49)-49)/12)*440;

return