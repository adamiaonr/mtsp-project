addpath('~/Workbench/mtsp-project/code/utils/')

%% 1) overall simulation parameters

% 1.1) different number of content objects
content_n = 100;

% 1.2) CS size (i.e. number of slots)
cs_size = 25;

% 1.3) number of simulation rounds (i.e. 'generate signals' -> 'fetch
% inputs' -> process inputs -> set outputs cycles)
round_n = 1000;

% 1.4) specify the topology matrix (commented case is a cascade 
% topology, 1 client, 3 levels - i.e. NDN routers - and 1 server).
clnt_n = 1;
rtr_n = 3;
srvr_n = 1;

topology = [0 1 0 0 0; 1 0 2 0 0; 0 1 0 2 0; 0 0 1 0 2; 0 0 0 1 0];

% 1.5) the router level matrix, i.e. the distribution of routers over the
% topology levels, codified in a nodes x rtr_level_n matrix
rtr_level_n = 3;

% 1.5.1) in this case, 1 router per level
rtr_level = [1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1];

% 1.6) content popularity, a zipf distribution, in the style of Carofiglio
% et al. 2011, p = c / (k^(alpha))
c = 0.8;
alpha = 1.0;
k = 1:1:content_n;
content_popularity = c ./ (k.^(alpha));

%% 2) simulation rounds
simulate(content_n, content_popularity, cs_size, 'LRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n);
simulate(content_n, content_popularity, cs_size, 'RANDOM', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n);
simulate(content_n, content_popularity, cs_size, 'MRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n);