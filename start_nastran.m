function start_nastran(out_file)
    nastran = '"C:\Program Files\Siemens\NX 8.5\NXNASTRAN\bin\nastran64Lw.exe"';
    is_it_start = 'tasklist | findstr /i nastran.exe';

    nastran = [nastran ' ' out_file ' parallel=4' ' out=' out_file(1:end-4)];
    fprintf(1, 'Start NX Solver\n%s\n', nastran);
    [status, cmdout] = system(nastran,'-echo');
    fprintf(1,'NX starting with status = %d (%s)\n', status, cmdout);
    if status
        exit('Nastran has error\nMATLAB finisinf work\n');
    end;

    count = 0;
    [status, cmdout] = system(is_it_start);
    while ~isempty(cmdout) 
        pause(5)
        fprintf(1,'%s has been working already %d s (status=%d)\n', cmdout(1:20), count * 5, status);
        [status, cmdout] = system(is_it_start);
        count = count + 1;    
    end;
end

