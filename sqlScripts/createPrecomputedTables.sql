CREATE TABLE filteredProdSales(
  product_id INTEGER,
  product_name TEXT,
  category_name TEXT,
  totalsale BIGINT
);

CREATE TABLE filteredStateSales(
  state_id INTEGER,
  state_name TEXT,
  category_name TEXT,
  totalsale BIGINT
);

CREATE TABLE filteredStateTopK(
  state_name TEXT,
  product_name TEXT,
  total BIGINT
);


CREATE TABLE oldProducts (
  product_id INTEGER,
  product_name TEXT,
  totalsale BIGINT
    );


CREATE TABLE newProducts (
  product_id INTEGER,
  product_name TEXT,
  totalsale BIGINT
    );

CREATE TABLE filteredOldProducts (
  product_id INTEGER,
  product_name TEXT,
  totalsale BIGINT
    );


CREATE TABLE filteredNewProducts (
  product_id INTEGER,
  product_name TEXT,
  totalsale BIGINT
    );



CREATE TABLE topSales(
  product_id INTEGER,
  product_name TEXT,
  totalsale BIGINT
);

INSERT INTO topSales(
  SELECT prod.id as product_id, prod.product_name AS product_name, COALESCE(totalsale, 0) AS total
  FROM product prod LEFT OUTER JOIN
    (SELECT product_id, SUM(totalsale) AS totalsale
     FROM
       (SELECT prod2.product_name AS product_name, p.person_name AS person_name, prod2.id AS product_id, (prod2.price * pc.quantity) AS totalsale
        FROM person p, product prod2, shopping_cart sc, products_in_cart pc
        WHERE p.id = sc.person_id
              AND sc.id = pc.cart_id
              AND sc.is_purchased = 'true'
              AND pc.product_id = prod2.id)
         AS custPurchases
     GROUP BY product_id)
      AS salesMade
      ON prod.id = product_id
);

INSERT INTO filteredProdSales(
  SELECT prod.id as product_id, prod.product_name AS product_name, salesMade.category_name AS category_name, COALESCE(totalsale, 0) AS total
  FROM product prod LEFT OUTER JOIN
    (SELECT product_id, category_name, SUM(totalsale) AS totalsale
     FROM
       (SELECT prod2.product_name AS product_name, p.person_name AS person_name, prod2.id AS product_id, cat.category_name, (prod2.price * pc.quantity) AS totalsale
        FROM person p, product prod2, shopping_cart sc, products_in_cart pc, category cat
        WHERE p.id = sc.person_id
              AND sc.id = pc.cart_id
              AND sc.is_purchased = 'true'
              AND pc.product_id = prod2.id
              AND prod2.category_id = cat.id)
         AS custPurchases
     GROUP BY product_id, category_name)
      AS salesMade
      ON prod.id = product_id
);

INSERT INTO oldProducts(
     SELECT product_id,product_name, totalsale
     FROM topSales
     ORDER BY totalsale DESC
     LIMIT 50
     );
INSERT INTO filteredOldProducts(
     SELECT product_id,product_name, totalsale
     FROM filteredProdSales
     ORDER BY totalsale DESC
     LIMIT 50
     );     
     
INSERT INTO newProducts(
     SELECT product_id,product_name, totalsale
     FROM topSales
     ORDER BY totalsale DESC
     LIMIT 50
    
    );

INSERT INTO filteredNewProducts(
     SELECT product_id,product_name, totalsale
     FROM filteredProdSales
     ORDER BY totalsale DESC
     LIMIT 50
    
    );

CREATE TABLE stateSales(
  state_id INTEGER,
  state_name TEXT,
  totalsale BIGINT
);

INSERT INTO stateSales(
  SELECT allstates.id AS state_id, allstates.state_name AS state_name, COALESCE(total,0) AS totalsale
  FROM
    (SELECT id as id, state_name as state_name FROM state) AS allstates
    LEFT OUTER JOIN
    (SELECT st.state_name AS state_name, SUM(pc.quantity * pc.price) AS total
    FROM shopping_cart sc2, products_in_cart pc, product p2, person p, state st
    WHERE pc.cart_id = sc2.id
    AND pc.product_id = p2.id
    AND sc2.person_id = p.id
    AND p.state_id = st.id
    GROUP BY st.state_name
    ) AS purchasesperstate
    ON allstates.state_name = purchasesperstate.state_name
  ORDER BY total_sale desc
);

INSERT INTO filteredStateSales(
  SELECT allstates.id AS state_id, allstates.state_name AS state_name, purchasesperstate.category_name AS category_name, COALESCE(total,0) AS total_sale
  FROM
    (SELECT id as id, state_name as state_name FROM state) AS allstates
    LEFT OUTER JOIN
    (SELECT st.state_name AS state_name, cat.category_name AS category_name, SUM(pc.quantity * pc.price) AS total
    FROM shopping_cart sc2, products_in_cart pc, product p2, person p, state st, category cat
    WHERE pc.cart_id = sc2.id
    AND pc.product_id = p2.id
    AND sc2.person_id = p.id
    AND p.state_id = st.id
    AND p2.category_id = cat.id
    GROUP BY st.state_name, cat.category_name
    ) AS purchasesperstate
    ON allstates.state_name = purchasesperstate.state_name
  ORDER BY total_sale desc
);


CREATE TABLE stateTopK(
  state_name TEXT,
  product_name TEXT,
  total BIGINT
);

INSERT INTO stateTopK(
  SELECT prodsAndStates.state_name AS state_name, prodsAndStates.product_name AS product_name, COALESCE(total,0) AS total
  FROM
    (SELECT state_name AS state_name, product_name AS product_name
    FROM product, state) AS prodsAndStates
    LEFT OUTER JOIN
      (SELECT st.state_name AS state_name, p2.product_name AS product_name, SUM(pc.quantity * pc.price) AS total
      FROM shopping_cart sc2, products_in_cart pc, product p2, person p, state st
      WHERE pc.cart_id = sc2.id
      AND pc.product_id = p2.id
      AND sc2.person_id = p.id
      AND p.state_id = st.id
      GROUP BY (st.state_name,p2.product_name)
      ORDER BY p2.product_name
    ) AS salesMade
    ON prodsAndStates.state_name = salesMade.state_name
    AND prodsAndStates.product_name = salesMade.product_name
);