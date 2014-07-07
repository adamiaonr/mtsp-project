addpath('~/Workbench/mtsp-project/code/utils/')

% figure directories
figure_dir_cascade = '/home/adamiaonr/Dropbox/Workbench/PhD/mtsp/project/report/figures/experiments/cascade';
figure_dir_tree = '/home/adamiaonr/Dropbox/Workbench/PhD/mtsp/project/report/figures/experiments/tree';

%% 1.1) overall simulation parameters (cascade topology)

% 1.1.1) different number of content objects
content_n = 100;

% 1.1.2) CS size (i.e. number of slots)
cs_size = [10 25 50 75];

% 1.1.3) number of simulation rounds (i.e. 'generate signals' -> 'fetch
% inputs' -> process inputs -> set outputs cycles)
round_n = 10000;

% 1.1.4) specify the topology matrix (commented case is a cascade 
% topology, 1 client, 3 levels - i.e. NDN routers - and 1 server).
clnt_n = 1;
rtr_n = 3;
srvr_n = 1;

topology = [0 1 0 0 0; 1 0 2 0 0; 0 1 0 2 0; 0 0 1 0 2; 0 0 0 1 0];

% 1.1.5) the router level matrix, i.e. the distribution of routers over the
% topology levels, codified in a nodes x rtr_level_n matrix

% 1.1.5.1) in this case, 1 router per level
rtr_level = [1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1];

% 1.1.6) content popularity, a zipf distribution, in the style of Carofiglio
% et al. 2011, p = c / (k^(alpha))
c = 0.8;
alpha = 1.0;
k = 1:1:content_n;
content_popularity = c ./ (k.^(alpha));

%% 1.2) simulation rounds

% for j = 1:numel(cs_size)
% 
%     simulate(content_n, content_popularity, cs_size(j), 'LRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_cascade);
%     simulate(content_n, content_popularity, cs_size(j), 'MRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_cascade);
%     simulate(content_n, content_popularity, cs_size(j), 'RANDOM', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_cascade);
%     
% end

%% 2.1) overall simulation parameters (tree topology)

% 2.1.1) specify the topology matrix
clnt_n = 8;
rtr_n = 7;
srvr_n = 1;

topology = [
    % clnts
% column numbers in HEX
%   1 2 3 4 5 6 7 8 9 A B C D E F 10
    0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0; 
    0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0; 
    % rtrs
%   1 2 3 4 5 6 7 8 9 A B C D E F 10
    1 1 0 0 0 0 0 0 0 0 0 0 2 0 0 0; 
    0 0 1 1 0 0 0 0 0 0 0 0 2 0 0 0; 
    0 0 0 0 1 1 0 0 0 0 0 0 0 2 0 0; 
    0 0 0 0 0 0 1 1 0 0 0 0 0 2 0 0; 
    0 0 0 0 0 0 0 0 1 1 0 0 0 0 2 0; 
    0 0 0 0 0 0 0 0 0 0 1 1 0 0 2 0; 
    0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 2; 
    % srvr
%   1 2 3 4 5 6 7 8 9 A B C D E F 10
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0];

% 2.1.2) the router level matrix, i.e. the distribution of routers over the
% topology levels, codified in a nodes x rtr_level_n matrix
rtr_level_n = 5;

% 2.1.2.1) in this case, 1 router per level
rtr_level = [
    1 0 0 0 0; 
    1 0 0 0 0; 
    1 0 0 0 0; 
    1 0 0 0 0;
    1 0 0 0 0; 
    1 0 0 0 0; 
    1 0 0 0 0; 
    1 0 0 0 0;
    0 1 0 0 0; 
    0 1 0 0 0; 
    0 1 0 0 0; 
    0 1 0 0 0;
    0 0 1 0 0; 
    0 0 1 0 0; 
    0 0 0 1 0; 
    0 0 0 0 1;
    ];

%% 2.2) simulation rounds

for j = 1:numel(cs_size)

    simulate(content_n, content_popularity, cs_size(j), 'LRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_tree);
    simulate(content_n, content_popularity, cs_size(j), 'MRU', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_tree);
    simulate(content_n, content_popularity, cs_size(j), 'RANDOM', round_n, topology, clnt_n, rtr_n, rtr_level, srvr_n, figure_dir_tree);
    
end
