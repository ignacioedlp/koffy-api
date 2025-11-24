# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Statistics summary cards at the top
    panel "Estadísticas Generales" do
      table_for [
        ["Total Usuarios", User.count],
        ["Total Roasters", Roaster.count],
        ["Total Órdenes", Order.count],
        ["Total Cafés", Coffee.count]
      ] do
        column "Estadística" do |row|
          row[0]
        end
        column "Cantidad" do |row|
          row[1]
        end
      end
    end

    # Main content in two columns
    columns do
      # Left column
      column do
        # Panel: Últimos 15 usuarios nuevos
        panel "Últimos 15 Usuarios Nuevos" do
          table_for User.order(created_at: :desc).limit(15) do
            column "Email" do |user|
              link_to user.email, admin_user_path(user)
            end
            column "Nombre" do |user|
              user.name || "N/A"
            end
            column "Fecha de Registro", :created_at do |user|
              user.created_at.strftime("%d/%m/%Y %H:%M")
            end
            column "Confirmado" do |user|
              user.confirmed_at.present? ? status_tag("Sí", class: 'ok') : status_tag("No", class: 'warning')
            end
          end
        end

        # Panel: Top 10 Roasters por Promedio de Reseñas
        panel "Top 10 Roasters por Promedio de Reseñas" do
          top_roasters_by_rating = Roaster.joins(:reviews)
                                          .group("roasters.id")
                                          .select("roasters.*, AVG(reviews.rating) as avg_rating, COUNT(reviews.id) as reviews_count")
                                          .having("COUNT(reviews.id) > 0")
                                          .order("AVG(reviews.rating) DESC")
                                          .limit(10)
          
          table_for top_roasters_by_rating do
            column "Roaster" do |roaster|
              link_to roaster.name, admin_roaster_path(roaster)
            end
            column "Promedio" do |roaster|
              sprintf("%.2f", roaster.avg_rating.to_f)
            end
            column "Reseñas" do |roaster|
              roaster.reviews_count
            end
            column "Ubicación" do |roaster|
              roaster.location || "N/A"
            end
          end
        end

        # Panel: Últimos 10 Roasters Creados
        panel "Últimos 10 Roasters Creados" do
          table_for Roaster.order(created_at: :desc).limit(10) do
            column "Roaster" do |roaster|
              link_to roaster.name, admin_roaster_path(roaster)
            end
            column "Fecha de Creación", :created_at do |roaster|
              roaster.created_at.strftime("%d/%m/%Y %H:%M")
            end
            column "Activo" do |roaster|
              roaster.active? ? status_tag("Sí", class: 'ok') : status_tag("No", class: 'error')
            end
            column "Cafés" do |roaster|
              roaster.coffees.count
            end
          end
        end
      end

      # Right column
      column do
        # Panel: Top 10 Roasters por Cantidad de Órdenes
        panel "Top 10 Roasters por Cantidad de Órdenes" do
          top_roasters_by_orders = Roaster.joins(:orders)
                                          .group("roasters.id")
                                          .select("roasters.*, COUNT(orders.id) as orders_count")
                                          .order("COUNT(orders.id) DESC")
                                          .limit(10)
          
          table_for top_roasters_by_orders do
            column "Roaster" do |roaster|
              link_to roaster.name, admin_roaster_path(roaster)
            end
            column "Órdenes" do |roaster|
              roaster.orders_count
            end
            column "Promedio Rating" do |roaster|
              roaster.average_rating > 0 ? sprintf("%.2f", roaster.average_rating) : "Sin reseñas"
            end
            column "Ubicación" do |roaster|
              roaster.location || "N/A"
            end
          end
        end

        # Panel: Top 5 Mejores Cafés (por cantidad vendida)
        panel "Top 5 Mejores Cafés (por Cantidad Vendida)" do
          top_coffees_data = Coffee.joins(coffee_variants: { order_items: :order })
                                   .joins(:roaster)
                                   .where(orders: { status: ['confirmed', 'preparing', 'ready', 'completed'] })
                                   .group("coffees.id, coffees.name, coffees.roaster_id, roasters.name")
                                   .select("coffees.id, coffees.name, coffees.roaster_id, roasters.name as roaster_name, SUM(order_items.quantity) as total_sold")
                                   .order("SUM(order_items.quantity) DESC")
                                   .limit(5)
          
          # Preload coffee variants to avoid N+1 queries
          coffee_ids = top_coffees_data.map(&:id)
          coffees_with_variants = Coffee.where(id: coffee_ids).includes(:coffee_variants).index_by(&:id)
          
          table_for top_coffees_data do
            column "Café" do |coffee|
              link_to coffee.name, admin_coffee_path(coffee.id)
            end
            column "Roaster" do |coffee|
              link_to coffee.roaster_name, admin_roaster_path(coffee.roaster_id)
            end
            column "Unidades Vendidas" do |coffee|
              coffee.total_sold || 0
            end
            column "Precio Mínimo" do |coffee|
              coffee_obj = coffees_with_variants[coffee.id]
              if coffee_obj && coffee_obj.min_price
                "$#{sprintf("%.2f", coffee_obj.min_price)}"
              else
                "N/A"
              end
            end
            column "En Stock" do |coffee|
              coffee_obj = coffees_with_variants[coffee.id]
              if coffee_obj && coffee_obj.in_stock?
                status_tag("Sí", class: 'ok')
              else
                status_tag("No", class: 'error')
              end
            end
          end
        end

        # Panel: Estadísticas de Órdenes por Estado
        panel "Órdenes por Estado" do
          order_stats = Order.group(:status).count
          
          table_for order_stats.map { |status, count| { status: status, count: count } } do
            column "Estado" do |stat|
              stat[:status].capitalize
            end
            column "Cantidad" do |stat|
              stat[:count]
            end
          end
        end
      end
    end

    # Charts section
    columns do
      column do
        panel "Gráfico: Usuarios Registrados por Mes" do
          div id: "users-chart-container" do
            canvas id: "users-chart"
          end
        end
      end

      column do
        panel "Gráfico: Órdenes por Mes" do
          div id: "orders-chart-container" do
            canvas id: "orders-chart"
          end
        end
      end
    end

    columns do
      column do
        panel "Gráfico: Top 5 Roasters por Órdenes" do
          div id: "roasters-orders-chart-container" do
            canvas id: "roasters-orders-chart"
          end
        end
      end

      column do
        panel "Gráfico: Distribución de Reseñas" do
          div id: "reviews-chart-container" do
            canvas id: "reviews-chart"
          end
        end
      end
    end

    # Include Chart.js library and custom JavaScript
    script src: "https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js" do
    end

    script do
      # Pre-calculate data for charts to avoid N+1 queries
      # Group users by month (PostgreSQL compatible)
      # Using Arel.sql() to safely wrap raw SQL expressions
      date_trunc_sql = Arel.sql("DATE_TRUNC('month', created_at)")
      users_by_month = User.select(Arel.sql("DATE_TRUNC('month', created_at) as month, COUNT(*) as count"))
                           .group(date_trunc_sql)
                           .order(date_trunc_sql)
                           .map { |u| [u.month.strftime("%Y-%m"), u.count] }
                           .to_h
      
      # Group orders by month
      orders_by_month = Order.select(Arel.sql("DATE_TRUNC('month', created_at) as month, COUNT(*) as count"))
                             .group(date_trunc_sql)
                             .order(date_trunc_sql)
                             .map { |o| [o.month.strftime("%Y-%m"), o.count] }
                             .to_h
      
      # Top 5 roasters by orders
      top_roasters_data = Roaster.joins(:orders)
                                 .group("roasters.id, roasters.name")
                                 .select("roasters.name, COUNT(orders.id) as orders_count")
                                 .order("COUNT(orders.id) DESC")
                                 .limit(5)
                                 .map { |r| [r.name, r.orders_count] }
                                 .to_h
      
      # Reviews distribution by rating
      reviews_by_rating = Review.group(:rating)
                                .order(:rating)
                                .count
                                .transform_keys { |k| k.to_f.to_s }
      
      raw <<-JAVASCRIPT
        // Wait for Chart.js to load
        document.addEventListener('DOMContentLoaded', function() {
          // Chart 1: Usuarios registrados por mes
          const usersData = #{users_by_month.to_json};
          const usersCtx = document.getElementById('users-chart');
          if (usersCtx) {
            new Chart(usersCtx, {
              type: 'line',
              data: {
                labels: Object.keys(usersData).sort(),
                datasets: [{
                  label: 'Usuarios Registrados',
                  data: Object.keys(usersData).sort().map(key => usersData[key]),
                  borderColor: 'rgb(75, 192, 192)',
                  backgroundColor: 'rgba(75, 192, 192, 0.2)',
                  tension: 0.1
                }]
              },
              options: {
                responsive: true,
                plugins: {
                  legend: {
                    display: true
                  }
                }
              }
            });
          }

          // Chart 2: Órdenes por mes
          const ordersData = #{orders_by_month.to_json};
          const ordersCtx = document.getElementById('orders-chart');
          if (ordersCtx) {
            new Chart(ordersCtx, {
              type: 'bar',
              data: {
                labels: Object.keys(ordersData).sort(),
                datasets: [{
                  label: 'Órdenes',
                  data: Object.keys(ordersData).sort().map(key => ordersData[key]),
                  backgroundColor: 'rgba(54, 162, 235, 0.6)',
                  borderColor: 'rgba(54, 162, 235, 1)',
                  borderWidth: 1
                }]
              },
              options: {
                responsive: true,
                plugins: {
                  legend: {
                    display: true
                  }
                }
              }
            });
          }

          // Chart 3: Top 5 Roasters por órdenes
          const roastersOrdersData = #{top_roasters_data.to_json};
          const roastersOrdersCtx = document.getElementById('roasters-orders-chart');
          if (roastersOrdersCtx) {
            new Chart(roastersOrdersCtx, {
              type: 'doughnut',
              data: {
                labels: Object.keys(roastersOrdersData),
                datasets: [{
                  label: 'Órdenes',
                  data: Object.values(roastersOrdersData),
                  backgroundColor: [
                    'rgba(255, 99, 132, 0.6)',
                    'rgba(54, 162, 235, 0.6)',
                    'rgba(255, 206, 86, 0.6)',
                    'rgba(75, 192, 192, 0.6)',
                    'rgba(153, 102, 255, 0.6)'
                  ],
                  borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)',
                    'rgba(153, 102, 255, 1)'
                  ],
                  borderWidth: 1
                }]
              },
              options: {
                responsive: true,
                plugins: {
                  legend: {
                    display: true,
                    position: 'bottom'
                  }
                }
              }
            });
          }

          // Chart 4: Distribución de reseñas (por rating)
          const reviewsData = #{reviews_by_rating.to_json};
          const reviewsCtx = document.getElementById('reviews-chart');
          if (reviewsCtx) {
            new Chart(reviewsCtx, {
              type: 'bar',
              data: {
                labels: Object.keys(reviewsData).sort().map(r => parseFloat(r).toFixed(1) + ' estrellas'),
                datasets: [{
                  label: 'Cantidad de Reseñas',
                  data: Object.keys(reviewsData).sort().map(key => reviewsData[key]),
                  backgroundColor: 'rgba(153, 102, 255, 0.6)',
                  borderColor: 'rgba(153, 102, 255, 1)',
                  borderWidth: 1
                }]
              },
              options: {
                responsive: true,
                plugins: {
                  legend: {
                    display: true
                  }
                },
                scales: {
                  y: {
                    beginAtZero: true,
                    ticks: {
                      stepSize: 1
                    }
                  }
                }
              }
            });
          }
        });
      JAVASCRIPT
    end

    # Custom CSS for better styling
    style do
      raw <<-CSS
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 15px;
          margin-top: 10px;
        }
        .stat-card {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 20px;
          border-radius: 8px;
          text-align: center;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-card h3 {
          margin: 0;
          font-size: 2em;
          font-weight: bold;
        }
        .stat-card p {
          margin: 5px 0 0 0;
          font-size: 0.9em;
          opacity: 0.9;
        }
        #users-chart-container, #orders-chart-container,
        #roasters-orders-chart-container, #reviews-chart-container {
          height: 300px;
          margin-top: 10px;
        }
      CSS
    end
  end # content
end
