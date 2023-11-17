% % %% This script analyzes the probability of a striosomal burst in response to
% % %  a Matrix Neuron burst as a function of Matrix firing rate. Specifically, it
% % %  analyzes the behaviour in 3 different time periods - baseline, in task,
% % %  and lick for a particular pair of neurons. The pair of neurons was
% % %  identified by looking at all possible pairs, and seeing if any
% % %  pair exhibited a difference in response probability as a function of
% % %  matrix firing rate.
% ROOT_DIR = 'Pattern Analysis';
% 
% twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
% twdbs = load(twdbs_dir);
% 
% twdb_control = twdbs.twdb_control;
% twdb_stress = twdbs.twdb_stress;
% twdb_stress2 = twdbs.twdb_stress2;
% 
% %
% dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through
% 
% % twdbs = {twdb_control};
% % dbs = {'control'};
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
    cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
    = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);


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
%% Find all Striosome, Matrix, and PLS neurons in each session
matrix_neurons = cell(1,length(dbs));
strio_neurons = cell(1,length(dbs));
pls_neurons = cell(1,length(dbs));
for db = 1:length(dbs)
    matrix_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    strio_neurons{db} = cell(1,length(sessionDir_neurons{db}));
    pls_neurons{db} = cell(1,length(sessionDir_neurons{db}));

    for sessionDir_idx = 1:length(sessionDir_neurons{db})
        matrix_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_matrix_ids{db});
        strio_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_strio_ids{db});
        pls_neurons{db}{sessionDir_idx} = intersect(sessionDir_neurons{db}{sessionDir_idx},cb_pls_ids{db});

    end
end


for db = 1:length(dbs)
    for sessionDir_idx = 1:length(pls_neurons{db})
        matrix_neuron_ids = matrix_neurons{db}{sessionDir_idx};
        strio_neuron_ids = strio_neurons{db}{sessionDir_idx};
        pls_neuron_ids = pls_neurons{db}{sessionDir_idx};

        if isempty(pls_neuron_ids) || isempty(strio_neuron_ids) 
%             display(pls_neuron_ids)
%             display(strio_neuron_ids)
%             display(matrix_neuron_ids)
            continue
        end

        for matrix_idx = 1:1%length(matrix_neuron_ids)
            for strio_idx = 1:1%length(strio_neuron_ids)
                for pls_idx = 1:1%length(pls_neuron_ids)
                    matrix_id = matrix_neuron_ids(matrix_idx);
                    strio_id = strio_neuron_ids(strio_idx);
                    pls_id = pls_neuron_ids(pls_idx);
                    disp(db);

                    %% Identify all the spikes
                    matrix_spikes = twdbs{db}(matrix_id).trial_spikes;
                    strio_spikes = twdbs{db}(strio_id).trial_spikes;
                    pls_spikes = twdbs{db}(pls_id).trial_spikes;

                    %% Get PLS bursts
                    pls_bursts = twdbs{db}(pls_id).trial_bursts;
                    %% Get Timings
                    matrix_timings = twdbs{db}(matrix_id).trial_evt_timings;
                    strio_timings = twdbs{db}(strio_id).trial_evt_timings;
                    pls_timings = twdbs{db}(strio_id).trial_evt_timings;

                    %% Get a plottable bins for PLS bursts
                        bins = ah_fill_burst_plotting_bins(pls_bursts, pls_timings, ...
        [1 100 twdbs{db}(pls_id).baseline_firing_rate_data], {}, {}, [200, 1, 2, .3, .6, 0], [0 0], [0 0 0]);

                    %% Graph the initial PLS burst
                    figure
                    subplot(2,1,1)
                    hold on
                    display([pls_spikes,pls_spikes]')
                    line([pls_spikes,pls_spikes]',repmat([0.6,0.9],[1,length(pls_spikes)]),'Color','black');
                    patch([pls_spikes(1),pls_spikes(end),pls_spikes(end),pls_spikes(1)],...
                        [0.6,0.6,0.9,0.9],'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

                    all_strio_spikes = sort(strio_spikes);
                    line([strio_spikes, strio_spikes]', repmat([0.1; 0.4],[1,length(strio_spikes)]),'Color','black');
                    ISI_thresholds = [mean(diff(all_strio_spikes)),mean(diff(all_strio_spikes))];

                    %% Create Second Plot Showing Firing Rate and Inhibition
                    subplot(2,1,2)
                    hold on
                    stairs(all_strio_spikes(1:end-1),log10(diff(all_strio_spikes)),'LineWidth',1,'Color','red');
                    [xb,yb] = stairs(all_strio_spikes(1:end-1),log10(diff(all_strio_spikes)));
                    aboveThreshold = (yb>=log10(ISI_thresholds(1)));
                    bottomLine=yb;
                    topLine = yb;
                    bottomLine(aboveThreshold)=NaN;
                    topLine(~aboveThreshold)=NaN;
                    plot(xb,bottomLine,'r','LineWidth',2);
                    plot(xb,topLine,'b','LineWidth',2);
                    line([0 2.5],log10(ISI_thresholds),'LineWidth',2,'Color','black');
                    xlabel('Time (s)');
                    ylabel('log ISI (s)')

                    hold off;
                end
            end
        end
    end
end