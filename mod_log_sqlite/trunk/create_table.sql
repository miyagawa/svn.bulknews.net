CREATE TABLE access_log (
    remote_host       varchar(50),
    remote_user       varchar(50),
    request_uri       varchar(50),
    virtual_host      varchar(50),
    time_stamp        integer unsigned not null,
    status            smallint(6),
    bytes_sent        integer,     
    referer           varchar(255),
    agent             varchar(255),
    request_method    varchar(6),
    request_protocol  varchar(10)      
);
