# are the 2700 mouse zero gene eQTLs enriched among human zero gene eQTLs

# mouse 0 gene eqtl mapping to nearest human 0 gene eqtl
x = read.table("mus_hum_neaest_zerg_imputed.sort.txt")
x.diff = abs(x[,3] - x[,5]);

# mouse geneful eqtl mapping to nearest human 0 gene eqtl
y = read.table("mus_hum_nearest_non0gene_imputed.sort.txt");
y.diff = abs(y[,3] - y[,5])

# there are 2761 mouse 0gene eqtls and 15343 geneful eqtls

radius = 15000;
num1 = length(x.diff[x.diff < radius]);
num2 = 2761 - num1;

num3 = length(y.diff[y.diff < radius]);
num4 = 15343 - num3;

mat = matrix(c(num1, num2, num3, num4), 2,2 );
chisq.test(mat)

