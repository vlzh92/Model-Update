function start_nastran(out_file)
%     nastran = '"c:\MSC.Software\MD_Nastran\bin\mdnastranw.exe"';
%     is_it_start = 'tasklist | findstr /i analysis.exe';
    p1 = 1; % ожидание результата сразу после запуска
    p2 = 1; % интервал запросов состояния nastran
    nastran = '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"';
    is_it_start = 'tasklist | findstr /i nastran.exe';

    nastran = [nastran ' ' out_file ' parallel=4' ' out=' out_file(1:end-4) ' scratch=yes'];
    fprintf(1, 'Start NX Solver\n%s\n', nastran);
    [status, cmdout] = system(nastran,'-echo');
    fprintf(1,'NX starting with status = %d (%s)\n', status, cmdout);
    if status
        exit('Nastran has error\nMATLAB finisinf work\n');
    end;
    pause(p1);
    count = 3;
    [status, cmdout] = system(is_it_start);
    while ~isempty(cmdout) 
        pause(p2)
        fprintf(1,'%s has been working already %d s (status=%d)\n', cmdout(1:10), count * 5, status);
        [status, cmdout] = system(is_it_start);
        count = count + 1;    
    end;
end
