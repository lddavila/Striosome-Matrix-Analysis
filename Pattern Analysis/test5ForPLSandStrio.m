% twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
% twdbs = load(twdbs_dir);
% 
% twdb_control = twdbs.twdb_control;
% twdb_stress = twdbs.twdb_stress;
% twdb_stress2 = twdbs.twdb_stress2; 
% 
% 
dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through

[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
           cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
           = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);
cb_matrix_ids = cb_pls_ids;
%% Find all sessions
homeDir = cd("..\Extracting Data From TWDB");
sessionDirs = cell(1,length(dbs));
sessionDir_neurons = cell(1,length(dbs)); % Neurons #s for each session
for db = 1:length(dbs)
    sessionDirs{db} = {twdbs{db}.sessionDir};
    
    [~,unique_sessionDir_idxs,~] = unique(sessionDirs{db});
    sessionDir_neurons{db} = cell(1,length(unique_sessionDir_idxs));
    for idx = 1:length(unique_sessionDir_idxs)
        sessionDir_neurons{db}{idx} = ...
            find(strcmp({twdbs{db}.sessionDir},sessionDirs{db}{unique_sessionDir_idxs(idx)}));
    end
    
    sessionDirs{db} = sessionDirs{db}(unique_sessionDir_idxs);
    for session_num = 1:length(sessionDirs{db})
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'/Users/Seba/Dropbox/UROP/stress_project','C:/Users/TimT5/Dropbox (MIT)/cell');
        sessionDirs{db}{session_num} = strrep(sessionDirs{db}{session_num},'D:\UROP','C:/Users/TimT5/Dropbox (MIT)/cell/Cell Figures and Data/Data');
    end
end
%% Find all Matrix and Striosomes in each session
comparison_type = 'Matrix to Striosomes';
matrix_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    matrix_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        matrix_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_matrix_ids{db}]);
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},[cb_swn_ids{db}]);
    end
end
%% Get pairs
all_matrix_strio_pairs = cell(1,length(dbs));
all_strio_strio_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_matrix_strio_pairs{db} = [all_matrix_strio_pairs{db}; allcomb(matrix_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx})];
        all_strio_strio_pairs{db} = [all_strio_strio_pairs{db}; allcomb(strio_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx})];
    end
end

%% Get the first 20 pairs of each 
all_strio_strio_pairs ={all_strio_strio_pairs{1}(1:90,:),all_strio_strio_pairs{2}(1:90,:),all_strio_strio_pairs{3}(1:90,:)};

all_matrix_strio_pairs ={all_matrix_strio_pairs{1}(1:90,:),all_matrix_strio_pairs{2}(1:90,:),all_matrix_strio_pairs{3}(1:90,:)};
%% Remove any Striosomes Connected to themselves
condition = all_strio_strio_pairs{1}(:,1) == all_strio_strio_pairs{1}(:,2);
all_strio_strio_pairs{1}(condition,:) = [];

condition = all_strio_strio_pairs{2}(:,1) == all_strio_strio_pairs{2}(:,2);
all_strio_strio_pairs{2}(condition,:) = [];

condition = all_strio_strio_pairs{3}(:,1) == all_strio_strio_pairs{3}(:,2);
all_strio_strio_pairs{3}(condition,:) = [];


%% Concatenate firing rates of all the pairs
cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
faliureCounter = {0,0,0};
strio_gc_matrix = {0,0,0};
matrix_gc_strio = {0,0,0};
pValuesOfStrioOnMatrix = {zeros(1,length(all_matrix_strio_pairs{1})),zeros(1,length(all_matrix_strio_pairs{2})),zeros(1,length(all_matrix_strio_pairs{1}))};
pValuesOfMatrixOnStrio = {zeros(1,length(all_matrix_strio_pairs{1})),zeros(1,length(all_matrix_strio_pairs{2})),zeros(1,length(all_matrix_strio_pairs{1}))};
nlags=30;
for currentDB=1:length(twdbs)
    currentDatabasePairs = all_matrix_strio_pairs{currentDB};
    currentDatabase = twdbs{currentDB};
    for currentPair=1:height(currentDatabasePairs)
        currentNeuronPair = currentDatabasePairs(currentPair,:);
        neuron_1_index =currentNeuronPair(1,1) ;
        neuron_2_index = currentNeuronPair(1,2);
        neuron_1_spikes = currentDatabase(neuron_1_index).trial_spikes;
        neuron_2_spikes = currentDatabase(neuron_2_index).trial_spikes;
        [xmean_matrix, ynew_matrix,edges] = concatenateFiringRatesOf2Neurons(neuron_1_spikes,neuron_2_spikes);
        %         disp(size([xmean_matrix.',ynew_matrix.']))
        Mdl = varm(2,nlags);
        Mdl.SeriesNames = {'Matrix FR has no effect','Striosome FR has no effect'};
        EstMdl = estimate(Mdl,[xmean_matrix.',ynew_matrix.']);
        %             summarize(EstMdl)
        [h,summary] = gctest(EstMdl,Display=false);
        %             disp(strcat("Database = " ,string(dbs{currentDB})))
        %             disp(strcat("Pair: ", string(neuron_1_index), " ", string(neuron_2_index)))
        %             disp(summary)
        %             display(summary.Decision(1))
        %             display(summary.Decision(2))
        if (strcmpi(summary.Decision(1),"Reject H0"))
            strio_gc_matrix{currentDB} = strio_gc_matrix{currentDB} +1;
            pValuesOfStrioOnMatrix{currentDB}(currentPair) = summary.PValue(1);
        end
        if (strcmpi(summary.Decision(2),"Reject H0"))
            matrix_gc_strio{currentDB} = matrix_gc_strio{currentDB}+1;
            pValuesOfMatrixOnStrio{currentDB}(currentPair) = summary.PValue(2);
        end

    end
end

%% Print Results of Running

% disp("Pairs that didn't work in Control");
% display(strcat(string(faliureCounter{1}),"/",string(length(all_matrix_strio_pairs{1}))))
% disp("Pairs that didn't work in Stress");
% display(strcat(string(faliureCounter{2}),"/",string(length(all_matrix_strio_pairs{2}))))
% disp("Pairs that didn't work in Stress2");
% display(strcat(string(faliureCounter{3}),"/",string(length(all_matrix_strio_pairs{3}))))
disp(strcat("Number of Lags = ",string(nlags)))
disp(strcat("Number of striosomes which have effect on pls in Control Database: ", string(strio_gc_matrix{1}),"/",string(length(all_matrix_strio_pairs{1}))))
disp(strcat("Number of striosomes which have effect on pls in Stress Database: ", string(strio_gc_matrix{2}),"/",string(length(all_matrix_strio_pairs{2}))))
disp(strcat("Number of striosomes which have effect on pls in Stress2 Database: ", string(strio_gc_matrix{3}),"/",string(length(all_matrix_strio_pairs{3}))))
disp("________________________________________________________________________________________")
disp(strcat("Number of pls which have effect on strisomes in Control Database: ", string(matrix_gc_strio{1}),"/",string(length(all_matrix_strio_pairs{1}))))
disp(strcat("Number of pls which have effect on striosomes in Stress Database: ", string(matrix_gc_strio{2}),"/",string(length(all_matrix_strio_pairs{2}))))
disp(strcat("Number of pls which have effect on striosomes in Stress2 Database: ", string(matrix_gc_strio{3}),"/",string(length(all_matrix_strio_pairs{3}))))
disp("//////////////////////////////////////////////////////////////////////////////////////////////////////")
% 
% figure
% histogram(pValuesOfStrioOnMatrix{1},10)
% title("P Values of Striosomes Effect on Matrix In Control")
% 
% figure
% histogram(pValuesOfStrioOnMatrix{2},10)
% title("P Values of Striosomes Effect on Matrix In Stress")
% 
% figure
% histogram(pValuesOfStrioOnMatrix{3},10)
% title("P Values of Striosomes Effect on Matrix In Stress2")
% 
% figure
% histogram(pValuesOfMatrixOnStrio{1},10)
% title("P Values of Matrix Effects on Striosomes In Control")
% 
% figure
% histogram(pValuesOfMatrixOnStrio{2},10)
% title("P Values of Matrix Effects on Striosomes In Stress")
% 
% figure
% histogram(pValuesOfMatrixOnStrio{3},10)
% title("P Values of Matrix Effects on Striosomes In Stress2")

%% Find connectivities between strio-matrix pairs and strio-strio pairs using granger causality
% % Parameters: Window Size, Bin Size, Amount to slide window by, method of
% % combining trials, proportion over threshold or mean, spikes/bursts/method
% % of binning bursts
% min_time = -20; max_time = 20;
% bin_size = 0.1;
% window_size = 2.5;
% window_shift_size = 1;
% type = 'bursts';
% 
% [matrix_strio_connectivities,ms_ret] = pairs_gc(twdbs, dbs, comparison_type, all_matrix_strio_pairs, min_time, max_time, bin_size, window_size, window_shift_size, type);
% [strio_strio_connectivities,ss_ret] = pairs_gc(twdbs,dbs,'Striosomes to Striosomes',all_strio_strio_pairs,min_time, max_time, bin_size, window_size, window_shift_size, type);

% %% Go back to my pairs and look at them more closely
% for i=1:length(strio_strio_connectivities{1}{1})
%     if strio_strio_connectivities{1}{1}(i) > 0
%         disp(strio_strio_connectivities{1}{1}(i))
%         pairs = all_strio_strio_pairs{1}(i,:);
%         strio1 = pairs(1,1);
%         strio2 = pairs(1,2);
%         strio1_spikes = twdb_control(strio1).trial_spikes;
%         strio1_bursts = twdb_control(strio1).trial_bursts;
%         strio2_spikes = twdb_control(strio2).trial_spikes;
%         [inhib_times,phasic_FR_Pairs,tonic_FR_pairs] = find_phasic_time_delays_inhib(strio1_spikes,strio2_spikes,strio1_bursts,'Ignore','Ignore',10,0,10,'FR',1);
%     end
% end

% cd(homeDir)
% save("MS and SS Connectivities and retAll.mat",...
%     "matrix_strio_connectivities",...
%     "ms_ret",...
%     "strio_strio_connectivities",...
%     "ss_ret");