%Poisson calculation for FDR
% 9/16/2010 hg18

%-------------------------------
% Count # genes regulating each marker
% file format: genenum|gc coord|#markers
%-------------------------------
%gene = load('markers_regulating_genes_transFDR40.txt');
%gene = load('/media/G3data/fdr/2dplot/marginals_fdr/markers_reg_genes/markers_regulating_genes_transFDR40.txt');
gene = load('/media/G3data/fdr18/trans/regulated/genes_FDR30.txt');

mu = mean(gene(:,3));

%error in the old code?
%[numgene junk] = size(gene);

%get largest number of genes
numgene = max(gene(:,3));
%store them
pvals = zeros(1, numgene);
%calc Pr(regulating > i genes | mu)
for i=1:numgene
    %pvals(i) = 1 - poisscdf(gene(i,3)-1 , mu);
    pvals(i) = 1 - poisscdf(i-1 , mu);
end

%from here, put the pvals into the FDR calculation
%we then look for our desired FDR, say 40% in our list
%and look to see how many regulating genes corresponds to it
%  mean is 27
%  e.g. 37 is cutoff for 40% FDR
%       46           for  1% FDR
q = myfdr(pvals)
%cutoff40 = max(find(q>0.4))
cutoff30 = max(find(q>0.3))
cutoff1 = max(find(q>0.01))

%make the plot
fh = figure;
set(fh, 'color', 'white');

plot(gene(:,2), gene(:,3), 'b.', 'MarkerSize', 1);
set(gca, 'Xcolor', [0 0 0 ]);
set(gca, 'Ycolor', [0 0 0]);
xlim([0 3090000000]);
line([0 3090000000] ,[cutoff30 cutoff30], 'linewidth', 2);
line([0 3090000000] ,[cutoff1 cutoff1], 'color', 'red', 'linewidth', 2);
set(gca, 'TickDir', 'out');
set(gca, 'XTick', [247249719 490200868 689702695 880975758 1061833624 1232733616 ...
    1391555040 1537829866 1678103118 1813477855 1947930239 2080279773 2194422753 ...
    2300791338 2401130253 2489957507 2568732249 2644849402 2708661053 2771097017 ...
    2818041340 2867732772 3022646526 3080419480 ]);
set(gca, 'XTickLabel', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y'}) ;

print -dpng FDR3040/ymarginal_FDR3040.png
print -depsc2 -painters -adobecset FDR3040/ymarginal_FDR3040.eps

%-------------------------------
% Count number of genes regulated by each marker
%-------------------------------
% same steps as above
% mean is 208
% 224 is cutoff for 40% FDR
% 248 is cutoff for 1% FDR
%marker = load('/media/G3data/fdr18/trans/regulators/regulator_count.txt');
marker = load('/media/G3data/fdr18/trans/regulators/regulator_countFDR30.txt');
mu = mean(marker(:,3))
nummarkers = max(marker(:,3));
m_pvals = zeros(1, nummarkers)
for i=1:nummarkers
    m_pvals(i) = 1 - poisscdf(i-1, mu);
end
m_q = myfdr(m_pvals)
%m_cutoff40 = max(find(m_q>0.4))
m_cutoff30 = max(find(m_q>0.3))
m_cutoff1 = max(find(m_q>0.01))

%or do I calculate FDR for all markers? i.e., the old way...
%[nummarkers junk] = size(marker);

fhx = figure();
set(fhx, 'color', 'white');
plot(marker(:,2), marker(:,3), 'bo', 'MarkerSize', 1);
set(gca, 'Xcolor', [ 0 0 0]);
set(gca, 'Ycolor', [0 0 0]);
xlim([0 3090000000]);
line([0 3090000000] ,[m_cutoff30 m_cutoff30], 'linewidth', 2);
line([0 3090000000] ,[m_cutoff1 m_cutoff1], 'color', 'red', 'linewidth', 2);

%chromsome labels
%set(gca, 'Color', 'black');
set(gca, 'XTick', [247249719 490200868 689702695 880975758 1061833624 1232733616 ...
    1391555040 1537829866 1678103118 1813477855 1947930239 2080279773 2194422753 ...
    2300791338 2401130253 2489957507 2568732249 2644849402 2708661053 2771097017 ...
    2818041340 2867732772 3022646526 3080419480 ])
set(gca, 'TickDir', 'out')
set(gca, 'XTickLabel', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y'}) 

print -dpng FDR3040/xmarginal_FDR3040.png
print -depsc2 -painters -adobecset FDR3040/xmarginal_FDR3040.eps
