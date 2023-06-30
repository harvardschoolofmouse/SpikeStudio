function OK = isaxes(h)
    if strcmp(get(h,'type'),'axes')
      OK = 1;
    else
      OK = 0;
    end
end