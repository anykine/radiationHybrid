function output_txt = myfunction(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

%changed from precision 4 to 10 so genome coords displayed correctly
%output_txt = {['X: ',num2str(pos(1),4)],...
%    ['Y: ',num2str(pos(2),4)]};
output_txt = {['X: ',num2str(pos(1),10)],...
    ['Y: ',num2str(pos(2),10)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z1: ',num2str(pos(3),4)];
    output_txt{end+1} = ['Z:pval: ', num2str(10^(-1*pos(3)), 4)];
end
