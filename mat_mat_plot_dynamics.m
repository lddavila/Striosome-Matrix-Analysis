function [fig_handle,goodnessOfFit, significance,slope] =mat_mat_plot_dynamics(spikes_msn_matrix1, spikes_msn_matrix2, ...
    bintime_strio)
allPossibleGoodnessOfFit = [0 0 0 0 0];
%alter bin size from 1-5 and record all the rsquared for each fit
for i=1:5
    all_matrix1_counts = [];
    all_matrix2_counts = [];
    for spike_idx = 1: length(spikes_msn_matrix1)
    % Get matrix & striosome counts
        %get the number of spikes in each bin, and the edges of each bin
        %for striosome neurons
        [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_msn_matrix1(spike_idx)), i);
        %get the number of spikes in each bin for matrix neurons
        %we use the same number of edges that were found in the striosome
        %histcounts call
        msnmatrix_N =                       histcounts(cell2mat(spikes_msn_matrix2(spike_idx)), striosome_edges);
        %store the spike counts in some arrays
        %also divide their value by the striosome bin time
        all_matrix1_counts = [all_matrix1_counts striosome_N/i];
        all_matrix2_counts = [all_matrix2_counts msnmatrix_N/i];
    end


    %get the average spike value of the matrix neurons for each value of the
    %striosome neurons
    [xmean_matrix, ynew_matrix] = y_mean(all_matrix1_counts, all_matrix2_counts);
    
    if height(xmean_matrix) <3

    else
        
    end
    % Start Fitting to linear line and get rsquare error
    fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';

    [fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);
    
    slope=fitobj_matrix.a; 
    
    %find the significance between x and y
    [~,significance] = corrcoef([xmean_matrix, ynew_matrix]);
    
    significance = significance(1,2);
    allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;

end
[M,I] = max(allPossibleGoodnessOfFit);
all_matrix1_counts = [];
all_matrix2_counts = [];
for spike_idx = 1: length(spikes_msn_matrix1)
% Get matrix & striosome counts
    %get the number of spikes in each bin, and the edges of each bin
    %for striosome neurons
    [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_msn_matrix1(spike_idx)), I);
    %get the number of spikes in each bin for matrix neurons
    %we use the same number of edges that were found in the striosome
    %histcounts call
    msnmatrix_N =                       histcounts(cell2mat(spikes_msn_matrix2(spike_idx)), striosome_edges);
    %store the spike counts in some arrays
    %also divide their value by the striosome bin time
    all_matrix1_counts = [all_matrix1_counts striosome_N/I];
    all_matrix2_counts = [all_matrix2_counts msnmatrix_N/I];
end


%get the average spike value of the matrix neurons for each value of the
%striosome neurons
[xmean_matrix, ynew_matrix] = y_mean(all_matrix1_counts, all_matrix2_counts);


% Start Fitting to linear line and get rsquare error
fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
opts = fitoptions( 'Method', 'NonlinearLeastSquares');
opts.Display = 'Off';

[fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);

slope=fitobj_matrix.a; 

%find the significance between x and y
display(xmean_matrix.')
display(ynew_matrix.')
[~,significance] = corrcoef([xmean_matrix, ynew_matrix]);
display(strcat("Significance",string(significance)))
significance = significance(1,2);
display(strcat("Significance",string(significance)))
allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;    

hold on;
plot(fitobj_matrix, xmean_matrix, ynew_matrix, 'o');
ylabel('SWN Firing Rate (Hz) - matrix');
xlabel('SWN Firing Rate (Hz) - matrix');
title(sprintf('bin matrix=%.2f, bin matrix=%.2f, R^2 =%.3f, Significance=%.3f', ...
    I, I, gof_matrix.rsquare,significance));
b = gca; legend(b,'off');
fig_handle = gcf;

goodnessOfFit=gof_matrix.rsquare;


end