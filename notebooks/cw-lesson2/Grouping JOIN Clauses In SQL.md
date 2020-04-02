# Grouping JOIN Clauses In SQL

Here's something that I have touched on in my blog via examples, but I have never talked about it explicitly. It is the idea of grouping SQL JOIN clauses. Normally, when you join multiple tables together, you simply have one JOIN after another. In some situations, this is not always possible to do in a way that will return accurate data. In rare cases, you have to get creative with your joins to enforce the proper relationships. There are a few ways to do this, one of which is the grouped JOIN.

For example, imagine you had three tables: A, B, and C. You want to join all three tables together (A join B join C) in such a way that the following rules hold true:

1. You want to get ALL records in table A.
2. You want to get all records in table B that correspond to table A but ONLY IF there is also a record in table C that corresponds to table B.
Tables A, B, and C as concepts are a little hard to visualize, so let's try and put some real world objects in place. This is just an example I came up with to write the blog post so be sure that it is not the best scenario in which you would use this. Let's say instead we have tables: Company, Contact, and Phone. Each contact is associated with a single company and each phone number is associated to a single contact.

Now, to translate the A,B,C problem into the Company, Contact, Phone problem, we want to select all company records regardless as well as all related contacts but ONLY if those contacts also have a related phone number. Let's walk through some approaches and why they don't quite satisfy our needs.

As always, I need to create and populate some temporary tables that I can run my queries against. For all of the following examples, we are first running this code:

```sql
DECLARE @company TABLE (
		id INT,
		name VARCHAR( 30 )
	);

DECLARE @contact TABLE (
    id INT,
    name VARCHAR( 30 ),
    company_id INT
);

DECLARE @phone TABLE (
    name VARCHAR( 30 ),
    contact_id INT
);

INSERT INTO @company
(
    id,
    name
)(
    SELECT 1, 'Nylon Technology' UNION ALL
    SELECT 2, 'Edit.com' UNION ALL
    SELECT 3, 'HotKoko'
);

INSERT INTO @contact
(
    id,
    name,
    company_id
)(
    SELECT 1, 'Maria Bello', 1 UNION ALL
    SELECT 2, 'Christina Cox', 1 UNION ALL
    SELECT 3, 'Julia Stiles', 2 UNION ALL
    SELECT 4, 'Julie Ensike', 3

);

INSERT INTO @phone
(
    name,
    contact_id
)(
    SELECT '123-456-1890', 1 UNION ALL
    SELECT '123-456-5555', 4
);
```

Don't worry about understanding the temp table creation and population. It is secondary to the point of this post.

## Approach One

We know that we want to get all the companies and we want to get related contacts, but we don't need to get contacts. This means that the Company-Contact relationship does not need to be enforced and therefore, should be a LEFT OUTER JOIN. Then, let's just say we throw on another LEFT OUTER JOIN to get the phone numbers into contacts. This would look something like this:

```sql
/*
    Query for companies and contacts, but ONLY return
    contacts if there is an associated phone number.
*/

SELECT
    c.id,
    c.name,
    ( ct.name ) AS contact_name,
    ( p.name ) AS contact_phone
FROM
    @company c
LEFT OUTER JOIN
    @contact ct
ON
    c.id = ct.company_id
LEFT OUTER JOIN
    @phone p
ON
    ct.id = p.contact_id
```

Running this code, we get the following CFDump output:

![alt text](./grouped_sql_join_example_1.gif "CFDump output")

Notice that stringing JOIN clauses together (as we might usually do) doesn't work here because we end up returning two contacts, Christina Cox and Julia Stiles, that do not have an associated phone number. This breaks our Contact-Phone relationship rule.

## Approach Two

Building on approach one, we might think that to get around this, all we have to do is add a WHERE clause to get rid of the contacts that don't have phone numbers. That would be, we don't want to return any records in which the joined phone number is NULL:

```sql
/*
		Query for companies and contacts, but ONLY return
		contacts if there is an associated phone number.
*/
SELECT
    c.id,
    c.name,
    ( ct.name ) AS contact_name,
    ( p.name ) AS contact_phone
FROM
    @company c
LEFT OUTER JOIN
    @contact ct
ON
    c.id = ct.company_id
LEFT OUTER JOIN
    @phone p
ON
    ct.id = p.contact_id
WHERE
    p.name IS NOT NULL
```

Running this code, we get the following CFDump output:

![alt text](./grouped_sql_join_example_2.gif "CFDump output")

This got rid of the NULL phone numbers alright, but it also go rid of the third company, Edit.com, which only has contacts that lack phone numbers. This maintains the Contact-Phone relationship rule but violates the All Companies rule.

## Approach Three

Starting to see where this is tricky, right? Let's step back for a second and think about what we are trying to do. We need the Contact-Phone relationship to be always true. This is where we would traditionally use an INNER JOIN. But, at the same time, we don't care if a company has any contacts. This is where we would traditionally use the LEFT OUTER JOIN (which we already have in place). Ok, so now, you might now be tempted to just change the second LEFT OUTER JOIN to an INNER JOIN:

```sql
/*
		Query for companies and contacts, but ONLY return
		contacts if there is an associated phone number.
*/

SELECT
    c.id,
    c.name,
    ( ct.name ) AS contact_name,
    ( p.name ) AS contact_phone
FROM
    @company c
LEFT OUTER JOIN
    @contact ct
ON
    c.id = ct.company_id
INNER JOIN
    @phone p
ON
    ct.id = p.contact_id
```

Running this code, we get the following CFDump output:

![alt text](./grouped_sql_join_example_3.gif "CFDump output")

This looks just like the result in approach two. The problem here is that we are now INNER JOINning the result of Company-Contact to Phone. And, since there are only two contacts that have phone numbers, this filters it all down to only two phone numbers and their related records; essentially, this is making the Phone records the limiting factor of the overall query.

## Approach Four

Now that we have seen why all of our other approaches have failed, let's take a look at the grouped JOINs approach. We can group JOINs by using parenthesis to prioritize certain joins before other joins are executed. This is similar to PEMDAS in mathematics (where groups equations are evaluated before the equations that involve them). The syntax looks a little funny, but once you get used to it, it's pretty straightforward:

```sql
/*
		Query for companies and contacts, but ONLY return
		contacts if there is an associated phone number.
*/

SELECT
    c.id,
    c.name,
    ( ct.name ) AS contact_name,
    ( p.name ) AS contact_phone
FROM
    @company c
LEFT OUTER JOIN
    (
            @contact ct
        INNER JOIN
            @phone p
        ON
            ct.id = p.contact_id
    )
ON
    c.id = ct.company_id

```

Notice here that we are grouping the JOIN between the Contact and Phone tables. Notice also that this JOIN is an INNER JOIN because we only want to get contacts that have associated phone numbers. Once that group has been processed, we are then LEFT OUTER JOINing its result to the Company table. You will notice that in the ON clause of the LEFT OUTER JOIN, we can refer to the table aliasing created in the grouped join. You might be tempted to move that ON clause into the group, but it won't work.

Running this code, we get the following CFDump output:

![alt text](./grouped_sql_join_example_4.gif "CFDump output")

Now, you can see that we are returning all three companies which enforces are All Companies rule, and, we are only returning contacts who have a phone number. This satisfies all the rules that our query has to follow with minimal effort (if you know how to do it).

In approach four, I talk about "processing groups" and intermediary results, but I don't actually know what is going on behind the scenes. For all I know, the join grouping just gets translated into backend logic that the SQL server is following when it joins all three tables together.

## Alternate Approaches Without JOIN Grouping

Another way that I can thing of doing this is to join the Contact and Phone table as part of a sub select to which the Company table is then joined:

```sql
/*
		Query for companies and contacts, but ONLY return
		contacts if there is an associated phone number.
*/

SELECT
    c.id,
    c.name,
    t.contact_name,
    t.contact_phone
FROM
    @company c
LEFT OUTER JOIN
    (
        SELECT
            ct.company_id,
            ( ct.name ) AS contact_name,
            ( p.name ) AS contact_phone
        FROM
            @contact ct
        INNER JOIN
            @phone p
        ON
            ct.id = p.contact_id
    ) AS t
ON
    c.id = t.company_id
```

This accomplishes the same thing, and is sort of doing the same thing (in terms of intermediary results) if you think about it, but look at it. Not pretty. Not only do we have to create an inline result set that, itself, has to be aliased, we also have to worry about selecting all the columns we want to return in the INNER JOIN and then our primary query has to query columns from that intermediary table with the intermediary table alias. I think you will find that once you are comfortable with the grouped JOIN, it is a much more elegant and maintainable solution.

Another alternate solution, and perhaps the most unattractive solution (in my opinion), is to turn the whole query on its head and do a RIGHT OUTER JOIN to the company table:

```sql
/*
		Query for companies and contacts, but ONLY return
		contacts if there is an associated phone number.
*/

SELECT
    c.id,
    c.name,
    ( ct.name ) AS contact_name,
    ( p.name ) AS contact_phone
FROM
    @phone p
INNER JOIN
    @contact ct
ON
    p.contact_id = ct.id
RIGHT OUTER JOIN
    @company c
ON
    ct.company_id = c.id
```

Here, we are first doing an INNER JOIN between the Phone and Contact which enforces our second rule. Then, we do a RIGHT OUTER JOIN to the company table which gets all the companies and any intermediary Contact-Phone results. This will get you the same results as above. The syntax here is very simple, but it's the approach that makes me feel very uncomfortable; we want to get Company records and yet, Company is the last table from which we are querying. This is more of a personal issue, but I feel that my "primary" content table should first. This way, your mentality matches the SQL statement. Don't twist your logic to conform to JOIN rules - use better syntax to align with your vision.... but that's just personal.

JOIN grouping is pretty powerful and can get you out of those sticky situations that involve mixed table relationship rules. I hope this was informative in some way.