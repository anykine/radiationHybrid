function output_txt = myfunction(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

%this gives me the data index, use this into the data array to get val
index = get(event_obj,'DataIndex');
idx = num2str(index);
pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)], ...
    ['index: ', num2str(index)], ...
    ['qval: ', mou(idx, 4)]};
    %should do x(index, 6) to get qvalue

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
