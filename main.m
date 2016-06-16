function output = main(tgt_path)

    try
        % Get important things into memory
		WaitSecs(0.001);
		GetSecs;
	    HideCursor;
		Screen('preference', 'verbosity', 1);
        warning('off', 'all');
		addpath(genpath('src'));

        % boilerplate initialization
        consts = Constants;
        ui.id = input('User id: ');
        ui.block = input('Block number: ');

        % read tgt file
        if nargin == 0
            tgt_name = GuessTgt(ui);
            tgt_path = ['misc/tfiles/', tgt_name];
        end
		[tgt, header, rest] = ParseTgt(tgt_path, ',');
        output = zeros(length(tgt.trial), 9); % id, block, trial, left_reward, right_reward, choice, t_choice
        output(:, 1) = ui.id;
        output(:, 2) = ui.block;
        output(:, 3) = tgt.trial;
        output(:, 4) = tgt.left_reward;
        output(:, 5) = tgt.right_reward;
        output(:, 6) = tgt.iti;


        % save the data in a flat file
        if ~exist('data', 'dir')
           mkdir('data');
        end

        % use the date in the filename to prevent overwrites
        date_string = datestr(now, 30);
        date_string = date_string(3:end - 2);
        tfile_string = tgt_path((max(strfind(tgt_path, '/'))+1):end - 4);
        filename = ['data/id', num2str(ui.id), '_', tfile_string, ...
                    '_', date_string, '.txt'];

        % write header!
        headers = {'id', 'block', 'trial', 'left_reward', 'right_reward', 'choice_1_left', 'time_choice', 'reward'};
        fid = fopen(filename, 'wt');
        csvFun = @(str)sprintf('%s,', str);
        xchar = cellfun(csvFun, headers, 'UniformOutput', false);
        xchar = strcat(xchar{:});
        xchar = strcat(xchar(1:end-1), '\n');
        fprintf(fid, xchar);
        fclose(fid);

        % initialize audio
        audio = PsychAudio(2);
        FillAudio(audio, 'misc/sounds/beep.wav', 1);
		FillAudio(audio, 'misc/sounds/smw_coin.wav', 2);

        screen = PsychScreen('reversed', consts.reversed,...
                             'big_screen', consts.big_screen, ...
                             'skip_tests', consts.skip_tests);

        % press_feedback = KeyFeedback(screen.dims(1), screen.dims(2),...
        %                              'num_boxes', 2);

        resp_device = KeyboardResponse(1:2,...
                                       'possible_keys', consts.possible_keys, ...
                                       'timing_tolerance', consts.timing_tolerance,...
                                       'force_min', consts.force_min,...
                                       'force_max', consts.force_max);
        Countdown(screen, resp_device); %todo: print correct keys

        WaitSecs(0.5); % breather before block starts

		points = 0;
        for ii = 1:length(tgt.trial)
            % Display 'GO!' at start of trial
			WipeScreen(screen);
            DrawFormattedText(screen.window, 'Go!',...
                              'center', 0.2 * screen.dims(1), screen.green);
		    DrawFormattedText(screen.window, ['+ ', num2str(points)], ...
			                  'center', 'center', screen.text_colour);
			% DrawOutline(press_feedback, screen.window);
			time_reference = FlipScreen(screen);
			StartKeyResponse(resp_device);
            PlayAudio(audio, 1, 0);

			% record first press
			temp_out = [-1 -1];
			feedback_vector = zeros(1, 2);
		    while temp_out(1) == -1
		        [temp_out, feedback_vector] = CheckKeyResponse(resp_device, feedback_vector);
		        WaitSecs(0.02);
		    end
            StopKeyResponse(resp_device);

			output(ii, 7) = temp_out(1);
			output(ii, 8) = temp_out(2) - time_reference;
            % display feedback
			if temp_out(1) == 1 && tgt.left_reward(ii) == 1
                PlayAudio(audio, 2, 0);
			    feedback_colour = 'green';
				points = points + 10;
                reward = 1;

			elseif temp_out(1) == 2 && tgt.right_reward(ii) == 1
                PlayAudio(audio, 2, 0);
			    feedback_colour = 'green';
				points = points + 10;
                reward = 1;
			else
			    feedback_colour = 'red';
                reward = 0;
			end
            output(ii, 9) = reward;

			WipeScreen(screen);
			DrawFormattedText(screen.window, ['+ ', num2str(points)], ...
				  'center', 'center', screen.text_colour);
            % DrawOutline(press_feedback, screen.window);
			% DrawFill(press_feedback, screen.window, feedback_colour, feedback_vector, 0);
			FlipScreen(screen);
			WaitSecs(0.2);
            % wait 200 ms until next trial
			WipeScreen(screen);
			DrawFormattedText(screen.window, ['+ ', num2str(points)], ...
				  'center', 'center', screen.text_colour);
            % DrawOutline(press_feedback, screen.window);
			FlipScreen(screen);
			WaitSecs(tgt.iti(ii));
        end

        WipeScreen(screen);
        DrawFormattedText(screen.window, ['Final Score: ', num2str(points)],...
                          'center', 'center', screen.text_colour);
        FlipScreen(screen);
        WaitSecs(1.5);
        csvwrite(filename, output, '-append');
		PsychPurge;

    catch err
        csvwrite(filename, output, '-append');
        PsychPurge;
        rethrow(err);
    end

end
