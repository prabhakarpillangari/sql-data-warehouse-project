<h1>Data Catalog for Gold Layer<h1>
<h2>Overview</h2>
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension 
tables and fact tables for specific business metrics.
<h2>1. gold.dim_customers</h2>
<ul>
  <li>Purpose: Stores customer details enriched with demographic and geographic data.</li>
  <li>Columns:</li>
</ul>
<table>
  <thead>
    <tr>
      <th>Column Name</th>
      <th>Data Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>customer_key</td>
      <td>INT</td>
      <td>Surrogate key uniquely identifying each customer record in the dimension table.</td>
    </tr>
    <tr>
      <td>customer_id</td>
      <td>INT</td>
      <td>Unique numerical identifier assigned to each customer.</td>
    </tr>
    <tr>
      <td>customer_number</td>
      <td>NVARCHAR(50)</td>
      <td>Alphanumeric identifier representing the customer, used for tracking and referencing.</td>
    </tr>
    <tr>
      <td>first_name</td>
      <td>NVARCHAR(50)</td>
      <td>The customer's first name, as recorded in the system.</td>
    </tr>
    <tr>
      <td>last_name</td>
      <td>NVARCHAR(50)</td>
      <td>The customer's last name or family name.</td>
    </tr>
    <tr>
      <td>country</td>
      <td>NVARCHAR(50)</td>
      <td>The country of residence for the customer (e.g., 'Australia').</td>
    </tr>
    <tr>
      <td>marital_status</td>
      <td>NVARCHAR(50)</td>
      <td>The marital status of the customer (e.g., 'Married', 'Single').</td>
    </tr>
    <tr>
      <td>gender</td>
      <td>NVARCHAR(50)</td>
      <td>The gender of the customer (e.g., 'Male', 'Female', 'n/a').</td>
    </tr>
    <tr>
      <td>birthdate</td>
      <td>DATE</td>
      <td>The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06).</td>
    </tr>
    <tr>
      <td>create_date</td>
      <td>DATE</td>
      <td>The date and time when the customer record was created in the system.</td>
    </tr>
  </tbody>
</table>
 <hr>
<h2>2. gold.dim_products</h2>
<ul>
  <li>Purpose: Provides information about the products and their attributes.</li>
  <li>Columns:</li>
</ul>
<table>
  <thead>
    <tr>
      <th>Column Name</th>
      <th>Data Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>product_key</td>
      <td>INT</td>
      <td>Surrogate key uniquely identifying each product record in the product dimension table.</td>
    </tr>
    <tr>
      <td>product_id</td>
      <td>INT</td>
      <td>A unique identifier assigned to the product for internal tracking and referencing.</td>
    </tr>
    <tr>
      <td>product_number</td>
      <td>NVARCHAR(50)</td>
      <td>A structured alphanumeric code representing the product, often used for categorization or inventory.</td>
    </tr>
    <tr>
      <td>product_name</td>
      <td>NVARCHAR(50)</td>
      <td>Descriptive name of the product, including key details such as type, color, and size.</td>
    </tr>
    <tr>
      <td>category_id</td>
      <td>NVARCHAR(50)</td>
      <td>A unique identifier for the product's category, linking to its high-level classification.</td>
    </tr>
    <tr>
      <td>category</td>
      <td>NVARCHAR(50)</td>
      <td>The broader classification of the product (e.g., Bikes, Components) to group related items.</td>
    </tr>
    <tr>
      <td>subcategory</td>
      <td>NVARCHAR(50)</td>
      <td>A more detailed classification of the product within the category, such as product type.</td>
    </tr>
    <tr>
      <td>maintenance_required</td>
      <td>NVARCHAR(50)</td>
      <td>Indicates whether the product requires maintenance (e.g., 'Yes', 'No').</td>
    </tr>
    <tr>
      <td>cost</td>
      <td>INT</td>
      <td>The cost or base price of the product, measured in monetary units.</td>
    </tr>
    <tr>
      <td>product_line</td>
      <td>NVARCHAR(50)</td>
      <td>The specific product line or series to which the product belongs (e.g., Road, Mountain).</td>
    </tr>
    <tr>
      <td>start_date</td>
      <td>DATE</td>
      <td>The date when the product became available for sale or use, stored in</td>
    </tr>
  </tbody>
</table>
 <hr>
<h2>2. gold.fact_sales</h2>
<ul>
  <li>Purpose: Stores transactional sales data for analytical purposes.</li>
  <li>Columns:</li>
</ul>
<table>
  <thead>
    <tr>
      <th>Column Name</th>
      <th>Data Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>order_number</td>
      <td>NVARCHAR(50)</td>
      <td>A unique alphanumeric identifier for each sales order (e.g., 'SO54496').</td>
    </tr>
    <tr>
      <td>product_key</td>
      <td>INT</td>
      <td>Surrogate key linking the order to the product dimension table.</td>
    </tr>
    <tr>
      <td>customer_key</td>
      <td>INT</td>
      <td>Surrogate key linking the order to the customer dimension table.</td>
    </tr>
    <tr>
      <td>order_date</td>
      <td>DATE</td>
      <td>The date when the order was placed.</td>
    </tr>
    <tr>
      <td>shipping_date</td>
      <td>DATE</td>
      <td>The date when the order was shipped to the customer.</td>
    </tr>
    <tr>
      <td>due_date</td>
      <td>DATE</td>
      <td>The date when the order payment was due.</td>
    </tr>
    <tr>
      <td>sales_amount</td>
      <td>INT</td>
      <td>The total monetary value of the sale for the line item, in whole currency units (e.g., 25).</td>
    </tr>
    <tr>
      <td>quantity</td>
      <td>INT</td>
      <td>The number of units of the product ordered for the line item (e.g., 1).</td>
    </tr>
    <tr>
      <td>price</td>
      <td>INT</td>
      <td>The price per unit of the product for the line item, in whole currency units (e.g., 25).</td>
    </tr>
  </tbody>
</table>
 
