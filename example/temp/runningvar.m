
m = randi(100);
n = randi(100);
x = randn(1, m);
y = randn(1, n);
mu_x = mean(x);
mu_y = mean(y);
ss_x = sum((x - mu_x).^2);
ss_y = sum((y - mu_y).^2);

k = m + n;
mu = (m*mu_x + n*mu_y) / k;
ss = sum(([x, y] - mu).^2);

[mu_c, ss_c, k_c] = combinestats(mu_x, ss_x, m, y);

fprintf('[mu=%f, ss=%f, k=%i], [mu=%f, ss=%f, k=%i]\n', mu, ss, k, mu_c, ss_c, k_c);


function [mu, ss, k] = combinestats(mu_x, ss_x, m, y)
    n = length(y);
    mu_y = mean(y);
    ss_y = sum((y - mu_y).^2);
    
    k = m + n;
    mu = (m*mu_x + n*mu_y) / k;
    
    delta = m*mu_x^2 + n*mu_y^2 - 2*(m*mu_x + n*mu_y)*mu + (m+n)*mu^2;
    ss = ss_x + ss_y + delta;
end