clear; clc
allFilesToLoad = ["AllControlMapsByTaskType.mat","AllStress 1MapsByTaskType.mat","AllStress 2MapsByTaskType.mat"];

allTitles =["Paired Short Excited Excited","Paired Short Excited Inhibited","Paired Short Inhibited Excited","Paired Short Inhibited Inhibited", "",...
    "","","","", "",...
    "Paired Long Excited Excited","Paired Long Excited Inhibited","Paired Long Inhibited Excited","Paired Long Inhibited Inhibited", "",...
    "","","","",""] ;
databases = ["control","stress1", "stress2"];
table_which_will_hold_everything = table([],[],[],[],[], ...
    'VariableNames', ...
    {'Database','Task Type and Conc','Pattern','Length','Pattern Count'});
for i=1:2.5
    load(allFilesToLoad(i));
    %     database_col = [];
    for j=1:length(allMaps)-5
        if strcmp(allTitles(j),"")
            continue;
        end
        database_col = [];
        for k=1:height(keys(allMaps{j}).')
            database_col = [database_col;databases(i);];
        end
        %         figure;
        %         hold on;
        %         disp(allTitles(j))
        %         disp([string(keys(allMaps{j})).',str2double(string(values(allMaps{j}).'))])
        length_col = [];
        allTitles_split = split(allTitles(j)," ");

        length_of_current = allTitles_split(2);
        for k=1:height(keys(allMaps{j}).')
            length_col = [length_col;length_of_current];
        end

        current_pattern = strcat(allTitles_split(3), " ", allTitles_split(4));
        current_pattern_col = [];
        for k=1:height(keys(allMaps{j}).')
            current_pattern_col = [current_pattern_col;current_pattern];
        end
        added_rows = table(database_col, ...
            string(keys(allMaps{j}).'), ...
            current_pattern_col,...
            length_col,...
            cell2mat(values(allMaps{j})).', ...
            'VariableNames', ...
            {'Database','Task Type and Conc','Pattern','Length','Pattern Count'});
        table_which_will_hold_everything = [table_which_will_hold_everything; added_rows];
        %         bar(categorical(string(keys(allMaps{j})).'),cell2mat(values(allMaps{j}).'))
        %         title(allTitles(j))
        %         xlabel("Task Type")
        %         ylabel("Normalized Pattern Count")
        %         hold off;
        %         disp(database_col)
    end

end

disp(table_which_will_hold_everything);

%% create the bar chart

%% get only Short CB and TR across Stress and Stress 2
list_of_patterns_i_want = ["Excited Excited","Excited Inhibited","Inhibited Excited","Inhibited Inhibited"];
list_of_task_type_i_want = ["Task Type CB", "Task Type TR"];
length_i_want = "Short";

for i =1:length(list_of_patterns_i_want)
    %     for j = 1:length(list_of_task_type_i_want)
    figure;
    hold on;
    task_type_i_want = list_of_task_type_i_want;
    pattern_i_want = list_of_patterns_i_want(i);
    table_of_only_what_I_want = table_which_will_hold_everything( ...
        (strcmp(table_which_will_hold_everything.('Task Type and Conc'),list_of_task_type_i_want(1)) | strcmp(table_which_will_hold_everything.('Task Type and Conc'),list_of_task_type_i_want(2)))& ...
        strcmp(table_which_will_hold_everything.('Pattern'),pattern_i_want) & ...
        strcmp(table_which_will_hold_everything.Length,length_i_want),:);
    %         disp(table_of_only_what_I_want)
    table_of_only_what_I_want = sortrows(table_of_only_what_I_want,"Task Type and Conc");
    disp(table_of_only_what_I_want)

    labels = categorical(strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));
    labels = reordercats(labels,strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));

    bar(labels,table_of_only_what_I_want.("Pattern Count"))
    title(strcat(pattern_i_want," ", task_type_i_want))
    %     end
end


%% get only Long CB and TR across Stress and Stress 2
list_of_patterns_i_want = ["Excited Excited","Excited Inhibited","Inhibited Excited","Inhibited Inhibited"];
list_of_task_type_i_want = ["Task Type CB", "Task Type TR"];
length_i_want = "Long";

for i =1:length(list_of_patterns_i_want)
    %     for j = 1:length(list_of_task_type_i_want)
    figure;
    hold on;
    task_type_i_want = list_of_task_type_i_want;
    pattern_i_want = list_of_patterns_i_want(i);
    table_of_only_what_I_want = table_which_will_hold_everything( ...
        (strcmp(table_which_will_hold_everything.('Task Type and Conc'),list_of_task_type_i_want(1)) | strcmp(table_which_will_hold_everything.('Task Type and Conc'),list_of_task_type_i_want(2)))& ...
        strcmp(table_which_will_hold_everything.('Pattern'),pattern_i_want) & ...
        strcmp(table_which_will_hold_everything.Length,length_i_want),:);
    %         disp(table_of_only_what_I_want)
    table_of_only_what_I_want = sortrows(table_of_only_what_I_want,"Task Type and Conc");
    disp(table_of_only_what_I_want)

    labels = categorical(strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));
    labels = reordercats(labels,strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));

    bar(labels,table_of_only_what_I_want.("Pattern Count"))
    title(strcat(pattern_i_want," ", task_type_i_want))
    %     end
end
%% plot the control patterns

list_of_patterns_i_want = ["Excited Excited","Excited Inhibited","Inhibited Excited","Inhibited Inhibited"];
list_of_task_type_i_want = ["Task Type CB", "Task Type TR", "Task Type EQR", "Task Type Rev CB"];
length_i_want = ["Short"];

for i =1:length(list_of_patterns_i_want)
    %     for j = 1:length(list_of_task_type_i_want)
    figure;
    hold on;
    task_type_i_want = list_of_task_type_i_want;
    pattern_i_want = list_of_patterns_i_want(i);
    table_of_only_what_I_want = table_which_will_hold_everything( ...
        (strcmpi(table_which_will_hold_everything.('Database'),"Control") )& ...
        strcmp(table_which_will_hold_everything.('Pattern'),pattern_i_want) & ...
        strcmp(table_which_will_hold_everything.Length,"Short"),:);
    %         disp(table_of_only_what_I_want)
    table_of_only_what_I_want = sortrows(table_of_only_what_I_want,"Pattern Count");
    disp(table_of_only_what_I_want)

    labels = categorical(strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));
    labels = reordercats(labels,strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));

    bar(labels,table_of_only_what_I_want.("Pattern Count"))
    title(strcat(pattern_i_want," ", task_type_i_want))
%     ylim([0,1.2])
    %     end
end

%% plot the control patterns

list_of_patterns_i_want = ["Excited Excited","Excited Inhibited","Inhibited Excited","Inhibited Inhibited"];
list_of_task_type_i_want = ["Task Type CB", "Task Type TR", "Task Type EQR", "Task Type Rev CB"];
length_i_want = "Long";

for i =1:length(list_of_patterns_i_want)
    %     for j = 1:length(list_of_task_type_i_want)
    figure;
    hold on;
    task_type_i_want = list_of_task_type_i_want;
    pattern_i_want = list_of_patterns_i_want(i);
    table_of_only_what_I_want = table_which_will_hold_everything( ...
        (strcmpi(table_which_will_hold_everything.('Database'),"Control") )& ...
        strcmp(table_which_will_hold_everything.('Pattern'),pattern_i_want) & ...
        strcmp(table_which_will_hold_everything.Length,length_i_want),:);
    %         disp(table_of_only_what_I_want)
    table_of_only_what_I_want = sortrows(table_of_only_what_I_want,"Pattern Count");
    disp(table_of_only_what_I_want)

    labels = categorical(strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));
    labels = reordercats(labels,strcat(table_of_only_what_I_want.Database, " ",table_of_only_what_I_want.('Task Type and Conc')," ", table_of_only_what_I_want.Length));

    bar(labels,table_of_only_what_I_want.("Pattern Count"))
    title(strcat(pattern_i_want," ", task_type_i_want))
%     ylim([0,1.2])
    %     end
end