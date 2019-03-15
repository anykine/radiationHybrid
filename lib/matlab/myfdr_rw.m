%courtesy of sangtae, annot by rw
% take a vector of pvalues and return vec of qvalues

% m = # of tests, p = vector of sorted pvals

function q = myfdr_rw(p,m)
p=p(:);
%yy is the sorted list, idx is orig index
m;
%basically, create a vector of m/rank and mult w/ pval vec
q = m./(1:m)'.*p;
%make sure q is a column vector
q = q(:);
%starting at bottom/end, if val to 
% for kk = 1:m-1,
%     q(m-kk) = min(q(m-kk), q(m-kk+1));
% end
q  ;
