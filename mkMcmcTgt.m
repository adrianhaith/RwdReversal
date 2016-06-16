function final_output = mkMcmcTgt(block_number, prop_left, prop_right, prop_swap, number_trials)
% block_number is the block number
% prop_left is the proportion of the time a reward is given for moving left
% prop_right is the proportion of the time a reward is given for moving right
% prop_swap is the proportion of the time through the trial that the roles switch
%
% Example:
% final_output = mkMcmcTgt(3, 0.1, 0.9, [.1, .4, .8], 100);
% block 3, 0.1 chance of reward on the left, 0.9 chance on the right,
% swap values 10%, 40%, and 80% of the way through the block
% saves to the misc/tfiles/ directory
% read with ParseTgt('misc/tfiles/<name>', ','); reads it into a struct

    rand('seed', block_number);
    final_output = zeros(number_trials, 4);
	final_output(:, 1) = block_number;
	final_output(:, 2) = 1:number_trials;
    final_output(:, 3) = binornd(1, prop_left, number_trials, 1);
    final_output(:, 4) = binornd(1, prop_right, number_trials, 1);
    final_output(:, 5) = .5 + rand(number_trials, 1);

	start_swap = round(prop_swap * number_trials);
    % let prop_swap be vector
    for ii = 1:length(prop_swap)
        if ii == 1
            start_swap = round(prop_swap(ii) * number_trials);
            stop_swap = number_trials;
        elseif ii == length(prop_swap)
            start_swap = round(prop_swap(ii) * number_trials);
            stop_swap = number_trials;
        else
            start_swap = round(prop_swap(ii - 1) * number_trials);
            stop_swap = round(prop_swap(ii) * number_trials);
        end
	    final_output(start_swap:stop_swap, [4, 3]) = final_output(start_swap:stop_swap, [3, 4]);
    end


    headers = {'block', 'trial', 'left_reward', 'right_reward', 'iti'};

	file_name = ['block', num2str(block_number), '.tgt'];
	out_path = 'misc/tfiles/';
	fid = fopen([out_path, file_name], 'wt');
	csvFun = @(str)sprintf('%s, ', str);
	xchar = cellfun(csvFun, headers, 'UniformOutput', false);
	xchar = strcat(xchar{:});
	xchar = strcat(xchar(1:end-1), '\n');
	fprintf(fid, xchar);
	fclose(fid);

    dlmwrite([out_path, file_name], final_output, '-append');

end
