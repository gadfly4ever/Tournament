-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


CREATE DATABASE tournament;
\c tournament;

CREATE TABLE Players (name text, idn serial PRIMARY KEY);
CREATE TABLE Matches (p1id serial REFERENCES Players(idn), p2id serial REFERENCES Players(idn), winner serial REFERENCES Players(idn), idn serial PRIMARY KEY);


-- Due to the issue with POSTGRESQL when using COUNT() and LEFT JOIN together, the VIEW was splitted in two:
CREATE VIEW MatchesPlayed AS SELECT Players.idn AS playerId, Matches.idn AS matchId 
FROM Players LEFT JOIN Matches 
ON Players.idn = Matches.p1id OR Players.idn = Matches.p2id;

CREATE VIEW MatchesPlayedNum AS SELECT playerId, COUNT(matchId) AS matchNum 
FROM MatchesPlayed 
GROUP BY playerId;


-- Same as above:
CREATE VIEW MatchesWon AS SELECT Players.idn AS playerId, Matches.idn AS matchId 
FROM Players LEFT JOIN Matches 
ON Players.idn = Matches.winner;

CREATE VIEW MatchesWonNum AS SELECT PlayerId, COUNT(matchId) AS winNum
FROM MatchesWon
GROUP BY PlayerId;


-- View for Player Standings:
CREATE VIEW Standings AS SELECT Players.idn, Players.name, MatchesWonNum.winNum, MatchesPlayedNum.matchNum
FROM Players, MatchesPlayedNum, MatchesWonNum 
WHERE Players.idn = MatchesPlayedNum.PlayerId AND Players.idn = MatchesWonNum.PlayerId
ORDER BY MatchesWonNum.winNum DESC;


CREATE VIEW Pairings AS SELECT p1.idn AS p1id, p1.name AS p1name, p2.idn AS p2id, p2.name AS p2name
FROM Standings AS p1, Standings AS p2 
WHERE p1.idn < p2.idn AND p1.winNum = p2.winNum AND p1.matchNum = p2.matchNum;

-- WHERE p1.idn < p2.idn AND p2.idn = p1.idn+1;
