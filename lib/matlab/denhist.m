function dummy = denhist(data, numbins)
% sample
    n = length(data);
		binwidth = range(data)/numbins;
		edg = min(data):binwidth:max(data);
		[count, bin] = histc(data, edg);
		h = bar(edg, count./(n*binwidth), 'histc');
		set(h, 'facecolor', [0.8 0.8 1]);
		set(h, 'edgecolor', [0.8 0.8 1]);
