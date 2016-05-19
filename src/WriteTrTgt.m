function WriteTrTgt(out_path, varargin)
    % day is the day (int)
    % block is the block (int)
    % swapped is a 1x2 vector of the swapped indices, or 0 if no swap 
    % image_type is 0 (hands) or 1 (symbols)
    % repeats is the number of repetitions for the entire array
    % easy_block overrides the image presentation times with some low number (1 = true)
    % copy-paste test:
	% WriteTrTgt(1, 1, [7 9], 0, 3, 0, 'D:/blam/finger-5/misc/tfiles/');
	
    opts = struct('day', 1, 'block', 1, 'swapped', 0, ...
                  'image_type', 0, 'repeats', 1, ...
                  'easy_block', 0, 'ind_finger', [7 8 9 10], ...
                  'ind_img', [7 8 9 10], 'times', 0.3:0.05:0.8);
    opts = CheckInputs(opts, varargin{:});
    
    day = opts.day;
    block = opts.block;
    swapped = opts.swapped;
    image_type = opts.image_type;
    repeats = opts.repeats;
    easy_block = opts.easy_block;
    ind_finger = opts.ind_finger;
    ind_img = opts.ind_img;
    time = opts.times;   
    
    seed = day * block;
    rand('seed', seed);
    ind_finger = [7 8 9 10];
    times = 0.3:0.05:0.8; % for 300ms period beep train

    combos = allcomb(times, ind_finger);
    combos(:, 3) = -1;
    for ii = 1:length(ind_finger)
        indices = find(combos(:,2) == ind_finger(ii));
        combos(indices, 3) = ind_img(ii);
    end

    combos = combos(randperm(size(combos, 1)), :);
    combo_size = size(combos, 1);

    if easy_block
        combos(:, 1) = min(times);
    end

    if any(swapped > 0)
        combos(:, 4) = swapped(1);
        combos(:, 5) = swapped(2);
        swapped2 = 1;
    else
        combos(:, 4:5) = 0;
        swapped2 = 0;
    end
    % combos is (times, finger, image, swap1, swap2)

    % add catch trials
    num_catch = floor(combo_size/10);
    randind = randi([-2 2], 1, num_catch);
    catchind = (10:10:combo_size) + randind;
    if catchind(end) > combo_size
        catchind(end) = combo_size;
    end
    % finger, img_time, indices of two swapped images
    catch_trial = [0 -1 -1 combos(1, 4:5)];
    combos = insertrows(combos, catch_trial, catchind);
    combo_size = size(combos, 1);

    final_output = [repmat(day, combo_size, 1) ...
                    repmat(block, combo_size, 1) ...
                    (1:combo_size)' ... % trials
                    repmat(easy_block, combo_size, 1) ...
                    repmat(swapped2, combo_size, 1) ...
                    repmat(image_type, combo_size, 1) combos];

    filename = ['tr_','dy',num2str(day), '_bk', num2str(block),...
                '_sw', num2str(swapped2), '_sh', num2str(image_type), '.tgt']; 
    headers = {'day', 'block', 'trial', 'easy', ...
               'swapped', 'image_type','image_time', 'finger_index',  ...
               'image_index', 'swap_index_1', 'swap_index_2'};		
           		   
	fid = fopen([out_path, filename], 'wt');
	csvFun = @(str)sprintf('%s, ',str);
	xchar = cellfun(csvFun, headers, 'UniformOutput', false);
	xchar = strcat(xchar{:});
	xchar = strcat(xchar(1:end-1), '\n');
	fprintf(fid, xchar);
	fclose(fid);
    dlmwrite([out_path, filename], final_output, '-append');
    
end              