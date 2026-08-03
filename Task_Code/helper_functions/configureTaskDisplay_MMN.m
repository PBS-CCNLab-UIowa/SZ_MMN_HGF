function configureTaskDisplay_MMN

screenmode      = 1;

%%%%%%%
screenres       = 3;                % 1 = 640 x 480 / 2 = 800 x 600 / 3 = 1024 x 768
fg_black        = [0 0 0];          % set foreground colour to black
bg_white        = [1 1 1];          % set background colour to white
ft_name         = 'Arial';          % Font
ft_size         = 25;               % size of font
n_buffers       = 60;               % # offscreen buffers
n_bits          = 0;                % # of bits per pixel: 0 = selects max. possible

config_display(screenmode, screenres, fg_black, bg_white, ft_name, ft_size, n_buffers, n_bits);
end

