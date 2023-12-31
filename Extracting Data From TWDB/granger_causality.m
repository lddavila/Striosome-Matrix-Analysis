function [GC2,ret] = granger_causality(X, plotthis)
% run Granger Causality test on the test case stored in the file testCase
% (adapted from cca_demo.m)

% disp('---------')
N     = length(X); % number of observations
PVAL  = 0.01;         % probability threshold for Granger causality significance

%since this was generated by an HMM, should be NLAGS=1 (?)
NLAGS = -1;            % if -1, best model order is assessed automatically
  
% set up the data
% X = [seq1;
%      seq2];
nvar = size(X,1);

% detrend and demean data
% disp('detrending and demeaning data');
X = cca_detrend(X);
X = cca_rm_temporalmean(X);
    
% find best model order
if NLAGS == -1,
%     disp('finding best model order ...');
    [bic,aic] = cca_find_model_order(X,2,12);
%     disp(['best model order by Bayesian Information Criterion = ',num2str(bic)]);
%     disp(['best model order by Aikaike Information Criterion = ',num2str(aic)]);
    NLAGS = max(aic,bic);
end

% find time-domain conditional Granger causalities [THIS IS THE KEY FUNCTION]
ret = cca_granger_regress(X,NLAGS,1);   % STATFLAG = 1 i.e. compute stats

% find significant Granger causality interactions (Bonferonni correction)
[PR,q] = cca_findsignificance(ret,PVAL,1);

% extract the significant causal interactions only
GC = ret.gc;
GC2 = GC.*PR;
GC2(isnan(GC2)) = 0;

% calculate causal connectivity statistics
causd = cca_causaldensity(GC,PR);
causf = cca_causalflow(GC,PR);

%-------------------------------------------------------------------------
if nargin > 1
    if ~plotthis
        return
    end
end

% plot time-domain granger results
figure(1); clf reset;
% FSIZE = 8;
colormap(flipud(bone));

% plot raw time series
for i=2:nvar,
    X(i,:) = X(i,:)+(10*(i-1));
end
subplot(231);
% set(gca,'FontSize',FSIZE);
plot(X');
axis('square');
set(gca,'Box','off');
xlabel('time');
set(gca,'YTick',[]);
xlim([0 N]);
title('Causal Connectivity Toolbox v2.0');

% plot granger causalities as matrix
subplot(232);
% set(gca,'FontSize',FSIZE);
imagesc(GC2);
colorbar;
axis('square');
set(gca,'Box','off');
title(['Granger causality, p<',num2str(PVAL)]);
xlabel('from');
ylabel('to');
set(gca,'XTick',[1:N]);
set(gca,'XTickLabel',1:N);
set(gca,'YTick',[1:N]);
set(gca,'YTickLabel',1:N);

% plot granger causalities as a network
subplot(233);
cca_plotcausality(GC2,[],5);

% plot causal flow  (bar = unweighted, line = weighted)
subplot(234);
% set(gca,'FontSize',FSIZE);
set(gca,'Box','off');
mval1 = max(abs(causf.flow));
mval2 = max(abs(causf.wflow));
mval = max([mval1 mval2]);
bar(1:nvar,causf.flow,'m');
ylim([-(mval+1) mval+1]);
xlim([0.5 nvar+0.5]);
set(gca,'XTick',[1:nvar]);
set(gca,'XTickLabel',1:nvar);
title('causal flow');
ylabel('out-in');
hold on;
plot(1:nvar,causf.wflow);
axis('square');

% plot unit causal densities  (bar = unweighted, line = weighted)
subplot(235);
% set(gca,'FontSize',FSIZE);
set(gca,'Box','off');
mval1 = max(abs(causd.ucd));
mval2 = max(abs(causd.ucdw));
mval = max([mval1 mval2]);
bar(1:nvar,causd.ucd,'m');
ylim([-0.25 mval+1]);
xlim([0.5 nvar+0.5]);
set(gca,'XTick',[1:nvar]);
set(gca,'XTickLabel',1:nvar);
title('unit causal density');
hold on;
plot(1:nvar,causd.ucdw);
axis('square');







