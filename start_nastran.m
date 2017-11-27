function start_nastran(out_file, conf)
%     nastran = '"c:\MSC.Software\MD_Nastran\bin\mdnastranw.exe"';
%     is_it_start = 'tasklist | findstr /i analysis.exe';
    p1 = conf.p1; % ожидание результата сразу после запуска
    p2 = conf.p2; % интервал запросов состояния nastran
%     nastran = '"D:\Siemens\NX\NXNASTRAN\bin\nastran64Lw.exe"';
    nastran = conf.nastran;
    is_it_start = conf.is_it_start;
    nas_param = conf.nas_param;

    nastran = [nastran ' ' out_file ' out=' out_file(1:end-4) ' ' nas_param];
    fprintf(1, 'Start NX Solver\n%s\n', nastran);
    [status, cmdout] = system(nastran,'-echo');
    fprintf(1,'NX starting with status = %d (%s)\n', status, cmdout);
    if status
        exit('Nastran has error\nMATLAB finisinf work\n');
    end
    pause(p1);
    count = 3;
    [status, cmdout] = system(is_it_start);
    while ~isempty(cmdout) 
        pause(p2)
        fprintf(1,'%s has been working already %d s (status=%d)\n', cmdout(1:10), p1 + count * p2, status);
        [status, cmdout] = system(is_it_start);
        count = count + 1;    
    end
end
