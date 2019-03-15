%courtesy of sangtae, annot by rw
% take a vector of pvalues and return vec of qvalues
function q = myfdr(p)

%yy is the sorted list, idx is orig index
[yy, idx] = sort(p(:));
m = length(yy);
%basically, create a vector of m/rank and mult w/ pval vec
q = m./(1:m)'.*yy;
%make sure q is a column vector
q = q(:);
%starting at bottom/end, if val to 
for kk = 1:m-1,
    q(m-kk) = min(q(m-kk), q(m-kk+1));
end
q(idx) = q;    
