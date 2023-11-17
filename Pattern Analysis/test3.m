%% This script analyzes the probability of a striosomal burst in response to
%  a Matrix Neuron burst as a function of Matrix firing rate. Specifically, it
%  analyzes the behaviour in 3 different time periods - baseline, in task,
%  and lick for a particular pair of neurons. The pair of neurons was
%  identified by looking at all possible pairs, and seeing if any
%  pair exhibited a difference in response probability as a function of
%  matrix firing rate.
ROOT_DIR = 'Pattern Analysis';

% twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
% twdbs = load(twdbs_dir);
%
% twdb_control = twdbs.twdb_control;
% twdb_stress = twdbs.twdb_stress;
% twdb_stress2 = twdbs.twdb_stress2;
%
%
dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through

% twdbs = {twdb_control};
% dbs = {'control'}; 
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
    cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
    = find_neuron_ids(twdbs, 'CB', [0,0,0,0,1]);


%% Find all sessions
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
%% Find all Striosome and Matrix neurons in each session
matrix_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    matrix_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));

    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        matrix_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_matrix_ids{db});
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_strio_ids{db});

    end
end

%% Get pairs
all_pairs = cell(1,length(dbs));
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        all_pairs{db} = [all_pairs{db}; allcomb(matrix_neurons{db}{sessionDir_idx},strio_neurons{db}{sessionDir_idx})];
    end
end

%%
periods = {'Baseline', 'In Task', 'Lick'};
for db = 1:length(dbs)
    for sessionDir_idx = 1:length(matrix_neurons{db})
        matrix_neuron_ids = matrix_neurons{db}{sessionDir_idx};
        strio_neuron_ids = strio_neurons{db}{sessionDir_idx};

        for matrix_idx = 1:length(matrix_neuron_ids)
            for strio_idx = 1:length(strio_neuron_ids)
                matrix_id = matrix_neuron_ids(matrix_idx);
                strio_id = strio_neuron_ids(strio_idx);
                disp(db);
                for period_idx = 1:length(periods)
                    period = periods{period_idx};
                    if strcmp(period, 'Baseline')
                        min_time = -10; max_time = -3;
                    elseif strcmp(period, 'In Task')
                        min_time = -3; max_time = 2.5;
                    elseif strcmp(period, 'Lick')
                        min_time = 2.5; max_time = 10;
                    end

                    % Identify ISIs
                    smooth_factor = 3;
                    min_ISIs_per_neuron = 0;
                    method = 'Tim';
                    debug_thresholds = false;
                    min_delay = .004; max_delay = .5;
                    debug = false;
                    matrix_probability_FRs = [];
                    strio_probability_FRs = [];
                    sizes = [47 ,242, 204];

                    % Identify bursts per trial
                    matrix_spikes = twdbs{db}(matrix_id).trial_spikes;
                    strio_spikes = twdbs{db}(strio_id).trial_spikes;
                    for trial_idx = 1:length(matrix_spikes)
                        % FIND_PHASIC_PERIODS finds periods of time in which the neuron with the
                        % given spikes is in the phasic/burst state.
                        matrix_bursts = find_phasic_periods(matrix_spikes(trial_idx), smooth_factor, min_ISIs_per_neuron, min_time, max_time, false, method, debug_thresholds);
                        strio_bursts = find_phasic_periods(strio_spikes(trial_idx), smooth_factor, min_ISIs_per_neuron, min_time, max_time, false, method, debug_thresholds);

                        if ~iscell(matrix_bursts) || ~iscell(strio_bursts)
                            continue;
                        end
                        % FIND_PHASIC_TIME_DELAYS finds correlated pairs of bursts between two
                        % neurons and reports distribution of time delays between the pairs of 
                        % bursts. A burst in a neuron is correlated with a burst in another neuron
                        % if the burst of the other neuron occurs within a certain time after the
                        % burst of the first neuron. Note that the relationship is NOT symmetric - 
                        % if a burst of neuron A is correlated with a burst of neuron B, the burst
                        % of neuron B is not necessarily correlated with the burst of neuron A.
                        [phasic_time_delays, FR_pairs, response_probability] = find_phasic_time_delays(matrix_spikes(trial_idx), strio_spikes(trial_idx), matrix_bursts, strio_bursts, ...
                            min_delay, max_delay, min_time, max_time, debug);

                        [strio_phasic_time_delays,strio_FR_pairs,strio_response_probability] = find_phasic_time_delays(strio_spikes(trial_idx),matrix_spikes(trial_idx), strio_bursts, matrix_bursts, ...
                            min_delay, max_delay, min_time, max_time, debug);
                        if isnan(response_probability)
                            continue;
                        end

                        matrix_FR = sum(matrix_spikes{trial_idx} > min_time & matrix_spikes{trial_idx} < max_time) / (max_time - min_time);
                        strio_FR = sum(strio_spikes{trial_idx} > min_time & strio_spikes{trial_idx} < max_time)/(max_time - min_time);
                        
                        matrix_probability_FRs = [matrix_probability_FRs; response_probability, matrix_FR];
                        strio_probability_FRs = [strio_probability_FRs; strio_response_probability,strio_FR];

                    end
                   

                    %% Create the Firing Rate For matrix
                    mMatrix = min(matrix_probability_FRs(:,2)); MMatrix = max(matrix_probability_FRs(:,2));
                    matrix_bin_size = (MMatrix-mMatrix)/num_bins;
                    matrix_bin_start = mMatrix; matrix_bin_end = matrix_bin_start + matrix_bin_size;
                    matrix_mean_resp_p = [];
                    for bin_idx = 1:num_bins
                        total = 0;
                        count = 0;
                        for idx = 1:size(matrix_probability_FRs,1)
                            if matrix_probability_FRs(idx,2) >= matrix_bin_start && matrix_probability_FRs(idx,2) < matrix_bin_end
                                if ~isnan(matrix_probability_FRs(idx,1))
                                    total = total + matrix_probability_FRs(idx,1);
                                    count = count + 1;
                                end
                            end
                        end
                        matrix_mean_resp_p = [matrix_mean_resp_p, total/count];

                        matrix_bin_start = matrix_bin_start + matrix_bin_size;
                        matrix_bin_end = matrix_bin_end + matrix_bin_size;
                    end
                    matrix_bins = linspace(mMatrix,MMatrix,num_bins+1);
                    matrix_bins = matrix_bins(1:end-1) + matrix_bin_size/2;

                    %% Create the bins for striosomes 
                    mStrio = min(strio_probability_FRs(:,2)); MStrio = max(strio_probability_FRs(:,2));
                    strio_bin_size = (MStrio-mStrio)/num_bins;
                    strio_bin_start = mStrio; strio_bin_end = strio_bin_start + strio_bin_size;
                    strio_mean_resp_p = [];
                    for bin_idx = 1:num_bins
                        total = 0;
                        count = 0;
                        for idx = 1:size(strio_probability_FRs,1)
                            if strio_probability_FRs(idx,2) >= strio_bin_start && strio_probability_FRs(idx,2) < strio_bin_end
                                if ~isnan(strio_probability_FRs(idx,1))
                                    total = total + strio_probability_FRs(idx,1);
                                    count = count + 1;
                                end
                            end
                        end
                        strio_mean_resp_p = [strio_mean_resp_p, total/count];

                        strio_bin_start = strio_bin_start + strio_bin_size;
                        strio_bin_end = strio_bin_end + strio_bin_size;
                    end
                    strio_bins = linspace(mStrio,MStrio,num_bins+1);
                    strio_bins = strio_bins(1:end-1) + strio_bin_size/2;

                    

                end
            end
        end
    end
end