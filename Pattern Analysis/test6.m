%% load databases
[dbs,twdbs] = loadData;

%% find neuron ids
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
    cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
    = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);
cd("..\Pattern Analysis")
[~,sessionDir_neurons] = findAllSessions(twdbs,dbs);
% cd("..\Pattern Analysis")

%% Get Pairs
% display(cb_strio_ids)
% theStrioIdsAsCell = twdb_lookup(twdbs{1}, 'index', 'key', 'tetrodeType', 'dms', ...
%     'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
%     'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
%     'key','taskType','TR');
% 
% cb_strio_ids = {cell2mat(theStrioIdsAsCell),0,0};
% 
% theMatrixIdsAsCell = twdb_lookup(twdbs{1}, 'index', 'key', 'tetrodeType', 'dms', ...
%     'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
%     'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
%     'key','taskType','TR');
% cb_matrix_ids = {cell2mat(theMatrixIdsAsCell),0,0};
% display(cb_strio_ids)
cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")
[neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);
all_matrix_strio_pairs = cutDownPairsToNPairs(80,all_matrix_strio_pairs);
all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);
nlags=1;

%% The important part
% I still need to keep track of Patterns,
%but now I need to specify where each count is goooooooing
%it can only be a short trial or a long trial
%where short is anything less than or equal to 2.49329
%and long is anything less than or equal to 4.46383 but still greater than the short trial
%these numbers are hardcoded into plotBins.m and can be changed if the need ever arises
%the variable shortOrLong tells us which this is 
    %shortOrLong=0 : short Trial
    %shortOrLong=1: long trial
    %shortOrLong=2: this is an edge case which indicates that the trial was unusually long, likely due to artifact 
%the variable pairedOrUnpaired tells us whether or not granger causality detected the pairs to be connected or not
    %pairedOrUnpaired =1: paired
    %pairedOrUnpaired =0: unpaired


eeC = {0,0,0};
eiC = {0,0,0};
ieC = {0,0,0};
iiC = {0,0,0};
%the structure of the following variables is as follows
%TrialCounter(databaseNumber)(Pattern You are Counting)
    %databaseNumber = 1 - control
    %databaseNumber = 2 - stress
    %databaseNumber = 3 - stress 2
    %Pattern You Are Counting = 1: striosome excited, matrix excited
    %Pattern You Are Counting = 1: striosome excited, matrix inhibited
    %Pattern You Are Counting = 1: striosome inhibited, matrix excited
    %Pattern You Are Counting = 1: striosome inhibited, matrix inhibited

pairedLongTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
pairedShortTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
pairedWeirdlyLongTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};

unpairedLongTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
unpairedShortTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
unpairedWeirdlyLongTrialCounter1 = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};


for currentDB=1:length(twdbs)
    currentDatabasePairs = all_matrix_strio_pairs{currentDB};
    currentDatabase = twdbs{currentDB};
    for currentPair=1:height(currentDatabasePairs)
        cd("..\Pattern Analysis")
        [result,pairedLongTrialCounterCurrent,pairedShortTrialCounterCurrent,pairedWeirdlyLongTrialCounterCurrent,...
    unpairedLongTrialCounterCurrent,unpairedShortTrialCounterCurrent,unpairedWeirdlyLongTrialCounterCurrent,...
    shortOrLong,pairedOrUnpaired]  = runGrangerCausality(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
        % UPDATE THE TOTAL COUNTS
        pairedLongTrialCounter1{currentDB}{1} = pairedLongTrialCounter1{currentDB}{1} + pairedLongTrialCounterCurrent{currentDB}{1};
        pairedLongTrialCounter1{currentDB}{2} = pairedLongTrialCounter1{currentDB}{2} + pairedLongTrialCounterCurrent{currentDB}{2};
        pairedLongTrialCounter1{currentDB}{3} = pairedLongTrialCounter1{currentDB}{3} + pairedLongTrialCounterCurrent{currentDB}{3};
        pairedLongTrialCounter1{currentDB}{4} = pairedLongTrialCounter1{currentDB}{4} + pairedLongTrialCounterCurrent{currentDB}{4};

        pairedShortTrialCounter1{currentDB}{1} = pairedShortTrialCounter1{currentDB}{1} + pairedShortTrialCounterCurrent{currentDB}{1};
        pairedShortTrialCounter1{currentDB}{2} = pairedShortTrialCounter1{currentDB}{2} + pairedShortTrialCounterCurrent{currentDB}{2};
        pairedShortTrialCounter1{currentDB}{3} = pairedShortTrialCounter1{currentDB}{3} + pairedShortTrialCounterCurrent{currentDB}{3};
        pairedShortTrialCounter1{currentDB}{4} = pairedShortTrialCounter1{currentDB}{4} + pairedShortTrialCounterCurrent{currentDB}{4};    

        pairedWeirdlyLongTrialCounter1{currentDB}{1} = pairedWeirdlyLongTrialCounter1{currentDB}{1} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
        pairedWeirdlyLongTrialCounter1{currentDB}{2} = pairedWeirdlyLongTrialCounter1{currentDB}{2} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
        pairedWeirdlyLongTrialCounter1{currentDB}{3} = pairedWeirdlyLongTrialCounter1{currentDB}{3} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
        pairedWeirdlyLongTrialCounter1{currentDB}{4} = pairedWeirdlyLongTrialCounter1{currentDB}{4} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{4};

%         disp(unpairedLongTrialCounter{currentDB}{1})
%         disp(unpairedLongTrialCounterCurrent{currentDB}{1})
        unpairedLongTrialCounter1{currentDB}{1} = unpairedLongTrialCounter1{currentDB}{1} + unpairedLongTrialCounterCurrent{currentDB}{1};
        unpairedLongTrialCounter1{currentDB}{2} = unpairedLongTrialCounter1{currentDB}{2} + unpairedLongTrialCounterCurrent{currentDB}{2};
        unpairedLongTrialCounter1{currentDB}{3} = unpairedLongTrialCounter1{currentDB}{3} + unpairedLongTrialCounterCurrent{currentDB}{3};
        unpairedLongTrialCounter1{currentDB}{4} = unpairedLongTrialCounter1{currentDB}{4} + unpairedLongTrialCounterCurrent{currentDB}{4};

        unpairedShortTrialCounter1{currentDB}{1} = unpairedShortTrialCounter1{currentDB}{1} + unpairedShortTrialCounterCurrent{currentDB}{1};
        unpairedShortTrialCounter1{currentDB}{2} = unpairedShortTrialCounter1{currentDB}{2} + unpairedShortTrialCounterCurrent{currentDB}{2};
        unpairedShortTrialCounter1{currentDB}{3} = unpairedShortTrialCounter1{currentDB}{3} + unpairedShortTrialCounterCurrent{currentDB}{3};
        unpairedShortTrialCounter1{currentDB}{4} = unpairedShortTrialCounter1{currentDB}{4} + unpairedShortTrialCounterCurrent{currentDB}{4};    

        unpairedWeirdlyLongTrialCounter1{currentDB}{1} = unpairedWeirdlyLongTrialCounter1{currentDB}{1} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
        unpairedWeirdlyLongTrialCounter1{currentDB}{2} = unpairedWeirdlyLongTrialCounter1{currentDB}{2} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
        unpairedWeirdlyLongTrialCounter1{currentDB}{3} = unpairedWeirdlyLongTrialCounter1{currentDB}{3} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
        unpairedWeirdlyLongTrialCounter1{currentDB}{4} = unpairedWeirdlyLongTrialCounter1{currentDB}{4} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{4};
%         close all
%         if  result== 1
%             break
%         end
%         
    end
    if result==1
        break
    end
end

%% Print Results of Counting Patterns
% disp("Control Database Pattern Counts")
% disp(strcat("Striosome Excitement, Matrix Excitement Count: ",string(eeC{1})))
% disp(strcat("Striosome Excitement, Matrix Inhibition Count: ",string(eiC{1})))
% disp(strcat("Striosome Inhibition, Matrix Excitement Count: ",string(ieC{1})))
% disp(strcat("Striosome Inhibition, Matrix Inhibition Count: ",string(iiC{1})))
% disp("__________________________________________________________________")

% pairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% pairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% pairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% 
% unpairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% unpairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% unpairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};

matrixStrioControlHeight = length(all_matrix_strio_pairs{1});
%% test
pairedLongTrialCounterTotalPatterns = sum(cell2mat(pairedLongTrialCounter1{1}));
unpairedLongTrialCounterTotalPatterns = sum(cell2mat(unpairedLongTrialCounter1{1}));

pairedShortTrialCounterTotalPatterns = sum(cell2mat(pairedShortTrialCounter1{1}));
unpairedShortTrialCounterTotalPatterns = sum(cell2mat(unpairedShortTrialCounter1{1}));

pairedWeirdlyLongTrialCounterTotalPatterns = sum(cell2mat(pairedWeirdlyLongTrialCounter1{1}));
unpairedWeirdlyLongTrialCounterTotalPatterns = sum(cell2mat(unpairedWeirdlyLongTrialCounter1{1}));


figure
hold on
lcounts = [pairedLongTrialCounter1{1}{1}/pairedLongTrialCounterTotalPatterns,unpairedLongTrialCounter1{1}{1}/unpairedLongTrialCounterTotalPatterns;...
    pairedLongTrialCounter1{1}{2}/pairedLongTrialCounterTotalPatterns,unpairedLongTrialCounter1{1}{2}/unpairedLongTrialCounterTotalPatterns;...
    pairedLongTrialCounter1{1}{3}/pairedLongTrialCounterTotalPatterns,unpairedLongTrialCounter1{1}{3}/unpairedLongTrialCounterTotalPatterns;...
    pairedLongTrialCounter1{1}{4}/pairedLongTrialCounterTotalPatterns,unpairedLongTrialCounter1{1}{4}/unpairedLongTrialCounterTotalPatterns];
bar(lcounts)
title("Control Database Pattern Counts Long Trials, paired by Granger Causality")
% legend("Paired Excited Excited","Unpaired Excited Excited","Paired Excited Inhibited","Unpaired Excited Inhibited","Paired Inhibited Excited","Unpaired Inhibited Excited","Paired Inhibited Inhibited","Unpaired Inhibited Inhibited")
hold off

figure
hold on
scounts = [pairedShortTrialCounter1{1}{1}/pairedShortTrialCounterTotalPatterns,unpairedShortTrialCounter1{1}{1}/unpairedShortTrialCounterTotalPatterns;...
    pairedShortTrialCounter1{1}{2}/pairedShortTrialCounterTotalPatterns,unpairedShortTrialCounter1{1}{2}/unpairedShortTrialCounterTotalPatterns;...
    pairedShortTrialCounter1{1}{3}/pairedShortTrialCounterTotalPatterns,unpairedShortTrialCounter1{1}{3}/unpairedShortTrialCounterTotalPatterns;...
    pairedShortTrialCounter1{1}{4}/pairedShortTrialCounterTotalPatterns,unpairedShortTrialCounter1{1}{4}/unpairedShortTrialCounterTotalPatterns];
bar(scounts)
title("Control Database Pattern Counts Short Trials, paired by Granger Causality")
% legend("Paired Excited Excited","Unpaired Excited Excited","Paired Excited Inhibited","Unpaired Excited Inhibited","Paired Inhibited Excited","Unpaired Inhibited Excited","Paired Inhibited Inhibited","Unpaired Inhibited Inhibited")
text(0.5,pairedShortTrialCounter1{1}{1},"Paired")
hold off

figure
hold on
WLcounts =[pairedWeirdlyLongTrialCounter1{1}{1}/pairedWeirdlyLongTrialCounterTotalPatterns,unpairedWeirdlyLongTrialCounter1{1}{1}/unpairedWeirdlyLongTrialCounterTotalPatterns;...
    pairedWeirdlyLongTrialCounter1{1}{2}/pairedWeirdlyLongTrialCounterTotalPatterns,unpairedWeirdlyLongTrialCounter1{1}{2}/unpairedWeirdlyLongTrialCounterTotalPatterns;...
    pairedWeirdlyLongTrialCounter1{1}{3}/pairedWeirdlyLongTrialCounterTotalPatterns,unpairedWeirdlyLongTrialCounter1{1}{3}/unpairedWeirdlyLongTrialCounterTotalPatterns;...
    pairedWeirdlyLongTrialCounter1{1}{4}/pairedWeirdlyLongTrialCounterTotalPatterns,unpairedWeirdlyLongTrialCounter1{1}{4}/unpairedWeirdlyLongTrialCounterTotalPatterns];
bar(WLcounts)
title("Control Database Pattern Counts Weirdly Long Trials, paired by Granger Causality")
% legend("Paired Excited Excited","Unpaired Excited Excited","Paired Excited Inhibited","Unpaired Excited Inhibited","Paired Inhibited Excited","Unpaired Inhibited Excited","Paired Inhibited Inhibited","Unpaired Inhibited Inhibited")
hold off


% disp("Stress Database Pattern Counts")
% disp(strcat("Striosome Excitement, Matrix Excitement Count: ",string(eeC{2})))
% disp(strcat("Striosome Excitement, Matrix Inhibition Count: ",string(eiC{2})))
% disp(strcat("Striosome Inhibition, Matrix Excitement Count: ",string(ieC{2})))
% disp(strcat("Striosome Inhibition, Matrix Inhibition Count: ",string(iiC{2})))
% disp("__________________________________________________________________")
% 
% disp("Stress2 Database Pattern Counts")
% disp(strcat("Striosome Excitement, Matrix Excitement Count: ",string(eeC{3})))
% disp(strcat("Striosome Excitement, Matrix Inhibition Count: ",string(eiC{3})))
% disp(strcat("Striosome Inhibition, Matrix Excitement Count: ",string(ieC{3})))
% disp(strcat("Striosome Inhibition, Matrix Inhibition Count: ",string(iiC{3})))