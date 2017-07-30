function kof = read_kof(kof_in)
    res = exist('kof.temp','file');
    if res==0
        f = fopen('kof.temp', 'w');
        fprintf(f, '%e\n', kof_in);
        fclose(f);
        fprintf(2, 'kof.temp has created whith value %e\n', kof_in);
        kof = kof_in;
        return;
    end;
    kof = str2num(read_line('kof.temp', 1));
    if kof ~= kof_in
        fprintf(2, 'kof have change from %e to %e\n', kof_in, kof);
    end;
end

