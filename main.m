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

        if nargin == 0
            tgt_name = GuessTgt(ui);
            tgt_path = ['misc/tfiles/', tgt_name];
        end
		[tgt, header, rest] = ParseTgt(tgt_path, ',');
        output = zeros(length(tgt.trial), 7); % id, block, trial, left_reward, right_reward, choice, t_choice
        output(:, 1) = ui.id;
        output(:, 2) = ui.block;
        output(:, 3) = tgt.trial;
        output(:, 4) = tgt.left_reward;
        output(:, 5) = tgt.right_reward;

        audio = PsychAudio(1);
        FillAudio(audio, 'misc/sounds/beep.wav', 1);

        screen = PsychScreen('reversed', consts.reversed,...
                             'big_screen', consts.big_screen, ...
                             'skip_tests', consts.skip_tests);

        press_feedback = KeyFeedback(screen.dims(1), screen.dims(2),...
                              'num_boxes', length(unique(tgt.finger_index)));

        valid_indices = unique(tgt.finger_index);
        resp_device = KeyboardResponse(valid_indices,...
                                       'possible_keys', consts.possible_keys, ...
                                       'timing_tolerance', consts.timing_tolerance,...
                                       'force_min', consts.force_min,...
                                       'force_max', consts.force_max);
        Countdown(screen, resp_device); %todo: print correct keys

        WaitSecs(0.5); % breather before block starts

		% use the date in the filename to prevent overwrites
		date_string = datestr(now, 30);
		date_string = date_string(3:end - 2);
		tfile_string = tgt_path((max(strfind(tgt_path, '/'))+1):end - 4);
		filename = ['data/id', num2str(ui.subject_id), '_', tfile_string, ...
		            '_', date_string, '.txt'];

        for ii = 1:length(tgt.trial)
            % Display 'GO!' at start of trial

            % record first press (see old version)

            % display feedback

            % wait 200 ms until next trial

        end

		% save data to mat file (and convert to flat?)
        % remove unused trials
        output.trial(structfind(output.trial, 'abs_time_on', -1)) = [];
        if ~exist('data', 'dir')
           mkdir('data');
        end

        % write header!
        dlmwrite(filename, output, '-append');
		PsychPurge;

    catch err
        PsychPurge;
        rethrow(err);
    end

end
