INSERT INTO sys_session.login (created_date, expired_date, username, session_id, ipv4_address)
VALUES(@created @expired, @user_code, @sessionid, @ip)