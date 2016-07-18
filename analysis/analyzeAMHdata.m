clear all
%load ../data/AMHdata
data = csvread('../data/id1_block2_160629T1727.txt',1,0);

% data columns:
% 1. subj id
% 2. block #
% 3. trial
% 4. left_reward
% 5. right_reward
% 6. trial_iti
% 7. choice_1_left
% 8. time_choice
% 9. reward
% 10. switch
% 11. rich side (1=left, 2=right)

Npre = 10; % number of trials pre-switch to plot
Npost = 40; % number of trials post-switch to plot
% identify rich=left trials
u = data(:,7); % selected action
reward = data(:,9); % reward

iswitchL = find(data(Npre+1:end-Npost,10)==1 & data(Npre+1:end-Npost,11)==1)+Npre;
iswitchR = find(data(Npre+1:end-Npost,10)==1 & data(Npre+1:end-Npost,11)==2)+Npre;

for i=1:length(iswitchL)
    uhistL(i,:) = data((iswitchL(i)-Npre):(iswitchL(i)+Npost),7);
end
for i=1:length(iswitchR)
    uhistR(i,:) = data((iswitchR(i)-Npre):(iswitchR(i)+Npost),7);
end
uAll = [uhistL; 3-uhistR];
%uAll = [3-uhistR];

figure(1); clf; hold on
plot([-Npre:Npost],mean(uAll)-1,'.-')
plot([0 0],[0 1],'k')

%% assess win/stay lose/stay
iwin = find(reward(1:end-1));
for i=1:length(iwin)
    stay_win(i) = (u(iwin(i)+1)==u(iwin(i)));
end
p_stay_win = mean(stay_win);

ilose = find(1-reward(1:end-1));
for i=1:length(ilose)
    stay_lose(i) = (u(ilose(i)+1)==u(ilose(i)));
end
p_stay_lose = mean(stay_lose);

%% second-order policy
win = reward(2:end-1);
win_prev = reward(1:end-2);
stay = (u(2:end-1)==u(3:end));
stay_prev = (u(1:end-2)==u(2:end-1));

B = [0 1];

for i = 1:2
    for j = 1:2
        for k = 1:2
            % find all trials that meet this criterion
            i_meet{i,j,k} = find(win_prev==B(i) & stay_prev==B(j) & win==B(k));
            p_stay(i,j,k) = mean(stay(i_meet{i,j,k}));
        end
    end
end

figure(2); clf; hold on
subplot(1,3,1); hold on
bar3([p_stay_lose p_stay_win]')
axis([.5 2.5 .5 2.5 0 1])
ylabel('1=lose, 2=win')
title('p(stay)')
%axis equal

%figure(3); clf; hold on
%colormap('pink')
subplot(1,3,2); hold on
title('p(stay) | lose')
bar3(p_stay(:,:,1))
%bar3([1 2; 3 4]/4)
xlabel('1=lose, 2=win')
ylabel('1=switch, 2=stay')
axis([.5 2.5 .5 2.5 0 1])
%axis equal

subplot(1,3,3); hold on
title('p(stay) | win')
bar3(5*p_stay(:,:,2))
bar3(5*p_stay(:,:,1))
xlabel('1=lose, 2=win')
ylabel('1=switch, 2=stay')
axis([.5 2.5 .5 2.5 0 1])
%axis equal

