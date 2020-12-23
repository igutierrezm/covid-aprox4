data {
    int<lower=0> Nlags; // number of lags.
    int<lower=0> Nedges; // number of edges.
    int<lower=0> Nareas; // number of areas.
    int<lower=0> Ntimes; // number of times/periods.
    int<lower=0> Npreds; // number of predictors.
    real<lower=0> i[Nareas]; // area id.
    real<lower=0> t[Ntimes]; // time id.
    int<lower=0> y[Ntimes, Nareas]; // observed counts.
    matrix[Nareas, Npreds] X[Ntimes]; // covariate vectors.
    int<lower=1, upper=Nareas> edge1[Nedges]; // 1st node of the edges.
    int<lower=1, upper=Nareas> edge2[Nedges]; // 2nd node of the edges.
}

transformed data {
    matrix[Nareas, Nlags] Ylags[Ntimes];
    for (id_time in (Nlags + 1):Ntimes) {
        for (id_area in 1:Nareas) {
            for (id_lag in 1:Nlags) {
                Ylags[id_time][id_area, id_lag] = 
                    max(y[id_time - id_lag][id_area], 1);
            }
        }
    }
}

parameters {
    vector<lower=0>[Nlags] w; // w.
    vector[Npreds] b; // b.
    vector[Nareas] u; // u.
    vector[Nareas] v; // v.
    real<lower=0> tu; // 1 / std(u).
    real<lower=0> tv; // 1 / std(v).
}

transformed parameters {
    // Variances
    real<lower=0> ou = 1.0 / sqrt(tu);
    real<lower=0> ov = 1.0 / sqrt(tv);
}

model {
    // Compute the contribution of v to the log-likelihood
    target += -0.5 * dot_self(v[edge1] - v[edge2]);

    // Specify a soft sum-to-zero constraint on v
    sum(v) ~ normal(0, 0.001 * Nareas);

    // Specify the role of the other parameters in the model
    for (j in (Nlags+1):Ntimes) {
        y[j] ~ poisson_log(log(Ylags[j] * w) + X[j] * b + ou * u + ov * v);
    }
    u  ~ normal(0, 1);
    b  ~ normal(0, 5);
    tu ~ gamma(3.2761, 1.81); // Carlin WinBUGS priors.
    tv ~ gamma(1.0000, 1.00); // Carlin WinBUGS priors.
    w  ~ gamma(1, 1);
}
