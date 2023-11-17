% clear; 
% close all
max_tseps = 600;
n_sim = 3500;
% columns are the different actions, rows are different plots
drift_rate = [1., 1.05];
titles = ["Non-impulcsive","Impulsive"];

n_action = length(drift_rate);
x = zeros(n_sim,n_action, max_tseps);
[actions_taken,time_dat] = deal(zeros(n_sim,1));
t_step=0.1;

% approximately what the mean will be
threshold = 3; %* (max(drift_rate)*(t_step))
noise = 1.0;

% rough_mean = /(max(drift_rate)*t_step)

%introduce a time lag, everything starts at 1.5

%% Simulations

%notes to mention
%in the actual data the distribution of mixture approach and choc approach are very different while in our simulations they are very similar
%my thoughts on how to fix this is by changing the default random number settings to generate one random number for action 1 and a different random number for action 2
%this way they can at least be somewhat different
%cause right now it's creading the random incrementation matrix by generating 2 random numbers from the distribution
%i think this will always cause the random numbers to be roughly equal in increasing
%but I'm not sure if that's osmething that we actually want
%also I played by my distributions of time of choice and they are now log(abs()) value scaled
%i believe this gives a better representation of the data
%i also want to chop the experiment time of choice data because it goes up to 600 in some cases which i think is really messing with the skewness 

for i=1:n_sim
    for j=2:max_tseps
        x(i,:,j) = x(i,:,j-1) + t_step*(drift_rate + noise*randn(1,n_action));
    end
    time = find(any(x(i,:,:) > threshold),1);
    if ~isempty(time)
        [~,actions_taken(i)] = max(x(i,:,time));
    else
        [~,action_taken(i)] = max(x(i,:,max_tseps));
    end
    if ~isempty(time)
        time_dat(i) = (time * t_step) ;
    else
        time_dat(i) = (max_tseps * t_step) ;
    end
    x(i,:,time+1:end) = nan;
end

figure; hold on
histogram(time_dat(actions_taken==1), linspace(0,600,6000))
histogram(time_dat(actions_taken==2), linspace(0,600,6000))
the_skew1 = skewness(time_dat(actions_taken==1));
the_skew2 = skewness(time_dat(actions_taken==2));


hold off
xlabel("time to decision")
ylabel('simulation count')
legend(strcat("Mixture",string(mean(time_dat(actions_taken==1)))),...
    strcat("Chocolate",string(mean(time_dat(actions_taken==2)))))

title(strcat("Skewness 1 : ",string(the_skew1)," Skewness 2: ",string(the_skew2)))
xlim([0,10])