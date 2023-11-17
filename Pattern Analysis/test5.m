%% Load neccessary Data
twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
twdbs = load(twdbs_dir);

twdb_control = twdbs.twdb_control;
twdb_stress = twdbs.twdb_stress;
twdb_stress2 = twdbs.twdb_stress2; 


dbs = {'control', 'stress', 'stress2'}; twdbs = {twdb_control, twdb_stress, twdb_stress2}; % Databases to loop through

[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
           cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
           = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);

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
all_strio_strio_pairs ={all_strio_strio_pairs{1}(1:10,:),all_strio_strio_pairs{2}(1:10,:),all_strio_strio_pairs{3}(1:10,:)};

all_matrix_strio_pairs ={all_matrix_strio_pairs{1}(1:10,:),all_matrix_strio_pairs{2}(1:10,:),all_matrix_strio_pairs{3}(1:10,:)};
%% Remove any Striosomes Connected to themselves
condition = all_strio_strio_pairs{1}(:,1) == all_strio_strio_pairs{1}(:,2);
all_strio_strio_pairs{1}(condition,:) = [];

condition = all_strio_strio_pairs{2}(:,1) == all_strio_strio_pairs{2}(:,2);
all_strio_strio_pairs{2}(condition,:) = [];

condition = all_strio_strio_pairs{3}(:,1) == all_strio_strio_pairs{3}(:,2);
all_strio_strio_pairs{3}(condition,:) = [];





%% Concatenate firing rates of all the pairs and run GC to check for connection between firing rates
% once something is found, then you can check for patterns
cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
faliureCounter = {0,0,0};
strio_gc_matrix = {0,0,0};
matrix_gc_strio = {0,0,0};
pValuesOfStrioOnMatrix = {zeros(1,length(all_matrix_strio_pairs{1})),zeros(1,length(all_matrix_strio_pairs{2})),zeros(1,length(all_matrix_strio_pairs{1}))};
pValuesOfMatrixOnStrio = {zeros(1,length(all_matrix_strio_pairs{1})),zeros(1,length(all_matrix_strio_pairs{2})),zeros(1,length(all_matrix_strio_pairs{1}))};
nlags=1;
% Parameters: Window Size, Bin Size, Amount to slide window by, method of
% combining trials, proportion over threshold or mean, spikes/bursts/method
% of binning bursts
min_time = -20; max_time = 20;
bin_size = 0.1;
window_size = 2.5;
window_shift_size = 1;
type = 'bursts';
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
            temp = neuron_1_spikes;
            neuron_1_spikes = neuron_2_spikes;
            neuron_2_spikes = temp;
            %if summary.Decision(1) == Reject H0 it means that the striosome firing rate has an effect on the matrix firing rate
            strio_gc_matrix{currentDB} = strio_gc_matrix{currentDB} +1;
            pValuesOfStrioOnMatrix{currentDB}(currentPair) = summary.PValue(1);
            %if Granger causality (GC) determines strio affects matrix, then we should check the pair for a pattern
            neuron_1_bursts = currentDatabase(neuron_1_index).trial_bursts;
            neuron_2_bursts = currentDatabase(neuron_2_index).trial_bursts;
            %             [inhib_times,phasic_FR_Pairs,tonic_FR_pairs] = find_phasic_time_delays_inhib(neuron_1_spikes,neuron_2_spikes,neuron_1_bursts,neuron_2_bursts,'Ignore','Ignore',10,0,10,'FR',1);
            for currentTrial=1:length(neuron_1_spikes)
                figure
                % Plot the Trial Bursts
                subplot(3,1,1)
                
                all_neuron_1_spikes = [];
                all_neuron_2_spikes = [];

                neuron_1_spikes_spike_i = neuron_1_spikes(currentTrial);
                neuron_1_spikes_spike_i = neuron_1_spikes_spike_i{1};
                line([neuron_1_spikes_spike_i,neuron_1_spikes_spike_i]',repmat([1-.4;1-.1],[1,length(neuron_1_spikes_spike_i)]),'Color','black');
                all_neuron_1_spikes = neuron_1_spikes_spike_i;
                %these spikes are plotted form 0.6-0.9

                neuron_2_spikes_spike_i = neuron_2_spikes(currentTrial);
                neuron_2_spikes_spike_i = neuron_2_spikes_spike_i{1};
                line([neuron_2_spikes_spike_i,neuron_2_spikes_spike_i]',repmat([1-.9; 1-.6],[1,length(neuron_2_spikes_spike_i)]),'Color','black');
                all_neuron_2_spikes = neuron_2_spikes_spike_i;
                title("Striosome (top) and Matrix (bottom) Bursts")
                xlim([-20 20])
                %these spikes are plotted from 0.1-0.4
                %so these are on bottom

                %             all_neuron_1_spikes = sort(all_neuron_1_spikes);
                %             all_neuron_2_spikes = sort(all_neuron_2_spikes);
                % Plot the Striosome Step Plot
                %             title("Striosomes On Top, Matrix on Bottom")
                neuron_1_ISI_threshold = [mean(diff(all_neuron_1_spikes)), mean(diff(all_neuron_1_spikes))];
                neuron_2_ISI_threshold = [mean(diff(all_neuron_2_spikes)), mean(diff(all_neuron_2_spikes))];

                subplot(3,1,2)
                for currentSection=1:5
                    for sectionBeginning=currentSection:5
                    end
                end
                hold on
                stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)),'LineWidth',1,'Color','red');

                [xb,yb] = stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)));
                aboveThreshold = (yb >= log10(neuron_1_ISI_threshold(1)));

                bottomLine = yb;
                topLine = yb;
                bottomLine(aboveThreshold) = NaN;
                topLine(~aboveThreshold) = NaN;
                plot(xb,bottomLine,'r','LineWidth',2);
                plot(xb,topLine,'b','LineWidth',2);
                line([-20 20], log10(neuron_1_ISI_threshold),'LineWidth',2,'Color','black');
                %             xlim(bounds(all_neuron_1_spikes));
                xlabel('Time (s)'); ylabel('log ISI (s)');
                title("Striosome Neuron")
                xlim([-20 20])
                % plot the Matrix Step-Plot
                subplot(3,1,3)
                hold on

                stairs(all_neuron_2_spikes(1:end-1),log10(diff(all_neuron_2_spikes)),'LineWidth',1,'Color','red');

                [xb,yb] = stairs(all_neuron_2_spikes(1:end-1),log10(diff(all_neuron_2_spikes)));
                aboveThreshold = (yb >= log10(neuron_2_ISI_threshold(1)));

                bottomLine = yb;
                topLine = yb;
                bottomLine(aboveThreshold) = NaN;
                topLine(~aboveThreshold) = NaN;
                plot(xb,bottomLine,'r','LineWidth',2);
                plot(xb,topLine,'b','LineWidth',2);
                line([-20 20], log10(neuron_2_ISI_threshold),'LineWidth',2,'Color','black');
                %             xlim(bounds(all_neuron_1_spikes));
                xlabel('Time (s)'); ylabel('log ISI (s)');
                title("Matrix Neuron")
                xlim([-20 20])

                sgtitle(strcat("Striosomes Neurons Affecting Matrix Neuron Database: ",string(dbs{currentDB})," Pair: ",string(currentPair)))
                hold off;
            end
            break
        end
        if (strcmpi(summary.Decision(2),"Reject H0"))
%             %if summary.Decision(2) == Reject H0 it means that the matrix firing rate has an effect on the strio firing rate
%             matrix_gc_strio{currentDB} = matrix_gc_strio{currentDB}+1;
%             pValuesOfMatrixOnStrio{currentDB}(currentPair) = summary.PValue(2);
%             %if Granger causality (GC) determines matrix affects strio, then we should check the pair for a pattern
% 
%             temp = neuron_1_spikes;
%             neuron_1_spikes = neuron_2_spikes;
%             neuron_2_spikes = temp; 
%             figure
%             subplot(2,1,1)
%             all_neuron_1_spikes = [];
%             all_neuron_2_spikes = [];
%             for i=1:1.5%length(neuron_1_spikes)
%                 neuron_1_spikes_spike_i = neuron_1_spikes(i);
%                 neuron_1_spikes_spike_i = neuron_1_spikes_spike_i{1};
%                 %                 neuron_1_spikes_spike_i = neuron_1_spikes_spike_i + (i*10);
%                 line([neuron_1_spikes_spike_i,neuron_1_spikes_spike_i]',repmat([1-.4;1-.1],[1,length(neuron_1_spikes_spike_i)]),'Color','black');
%                 all_neuron_1_spikes = [all_neuron_1_spikes;neuron_1_spikes_spike_i];
%             end
% 
%             for i=1:1.5%length(neuron_2_spikes)
%                 neuron_2_spikes_spike_i = neuron_2_spikes(i);
%                 neuron_2_spikes_spike_i = neuron_2_spikes_spike_i{1};
%                 %                 neuron_2_spikes_spike_i = neuron_2_spikes_spike_i + (i*10);
%                 line([neuron_2_spikes_spike_i,neuron_2_spikes_spike_i]',repmat([1-.9; 1-.6],[1,length(neuron_2_spikes_spike_i)]),'Color','black');
%                 all_neuron_2_spikes = [all_neuron_2_spikes;neuron_2_spikes_spike_i];
%             end
% %             all_neuron_1_spikes = sort(all_neuron_1_spikes);
% %             all_neuron_2_spikes = sort(all_neuron_2_spikes);
%             neuron_1_ISI_threshold = [mean(diff(all_neuron_1_spikes)), mean(diff(all_neuron_1_spikes))];
%             neuron_2_ISI_threshold = [mean(diff(all_neuron_2_spikes)), mean(diff(all_neuron_2_spikes))];
% 
%             subplot(2,1,2)
%             hold on
%             stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)),'LineWidth',1,'Color','red');
% 
%             [xb,yb] = stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)));
%             aboveThreshold = (yb >= log10(neuron_1_ISI_threshold(1)));
% 
%             bottomLine = yb;
%             topLine = yb;
%             bottomLine(aboveThreshold) = NaN;
%             topLine(~aboveThreshold) = NaN;
%             plot(xb,bottomLine,'r','LineWidth',2);
%             plot(xb,topLine,'b','LineWidth',2);
%             line([0 2.5], log10(neuron_1_ISI_threshold),'LineWidth',2,'Color','black');
% %             xlim(bounds(all_neuron_1_spikes));
%             xlabel('Time (s)'); ylabel('log ISI (s)');
%             title("Matrix Affects Striosome")
%             hold off;
        end

    end
end

    %% Print Results of Running

%     % disp("Pairs that didn't work in Control");
%     % display(strcat(string(faliureCounter{1}),"/",string(length(all_matrix_strio_pairs{1}))))
%     % disp("Pairs that didn't work in Stress");
%     % display(strcat(string(faliureCounter{2}),"/",string(length(all_matrix_strio_pairs{2}))))
%     % disp("Pairs that didn't work in Stress2");
%     % display(strcat(string(faliureCounter{3}),"/",string(length(all_matrix_strio_pairs{3}))))
%     disp(strcat("Number of Lags = ",string(nlags)))
%     disp(strcat("Number of striosomes which have effect on matrix in Control Database: ", string(strio_gc_matrix{1}),"/",string(length(all_matrix_strio_pairs{1}))))
%     disp(strcat("Number of striosomes which have effect on matrix in Stress Database: ", string(strio_gc_matrix{2}),"/",string(length(all_matrix_strio_pairs{2}))))
%     disp(strcat("Number of striosomes which have effect on matrix in Stress2 Database: ", string(strio_gc_matrix{3}),"/",string(length(all_matrix_strio_pairs{3}))))
%     disp("________________________________________________________________________________________")
%     disp(strcat("Number of matrix which have effect on strisomes in Control Database: ", string(matrix_gc_strio{1}),"/",string(length(all_matrix_strio_pairs{1}))))
%     disp(strcat("Number of matrix which have effect on striosomes in Stress Database: ", string(matrix_gc_strio{2}),"/",string(length(all_matrix_strio_pairs{2}))))
%     disp(strcat("Number of matrix which have effect on striosomes in Stress2 Database: ", string(matrix_gc_strio{3}),"/",string(length(all_matrix_strio_pairs{3}))))
%     disp("//////////////////////////////////////////////////////////////////////////////////////////////////////")

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
