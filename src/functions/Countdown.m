function zero_volts = Countdown(screen, resp_device)

    length_countdown = 6;
    start_zero = 3;
    stop_zero = 5;
    when = GetSecs + (1:length_countdown);

    for current = 1:length_countdown

        if isa(resp_device, 'ForceResponse')
            if length_countdown - current == stop_zero
                StartKeyResponse(resp_device);

            elseif length_countdown - current == start_zero
                StopKeyResponse(resp_device);
                zero_volts = CheckFullResponse(resp_device);
                zero_volts = mean(zero_volts, 1);
            end
        else % non-force-transducers
            zero_volts = [];
        end

        countdown_string = ['Experiment is starting in ',...
        num2str(length_countdown - current), ' seconds. \n\n',...
        'Keys are ', upper(resp_device.valid_keys{1}), ' and ', upper(resp_device.valid_keys{2})];

        DrawFormattedText(screen.window, countdown_string,...
                          'center', 'center', screen.text_colour);
        FlipScreen(screen, when(current));

    end
end
