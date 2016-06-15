function out = GuessTgt(ui)
    try
        tfiles = dir(fullfile('misc/tfiles/', '*.tgt'));
        tfiles = {tfiles.name}';
        index = find(cellfun('length', ...
                    regexp(tfiles, ['dy', num2str(ui.day), '_bk', num2str(ui.block), '_'])) == 1);
        out = tfiles{index};
    catch
        warning('No matching target file!')
        out = -1;
    end

end
