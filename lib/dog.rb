class Dog
  attr_accessor :id, :name, :breed

  @@all = []

  def initialize(id:nil, name: , breed: )
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    attributes = {:id => row[0], :name => row [1], :breed => row[2]}
    dog = self.new(attributes)
    dog
  end

  def self.find_by_name(name)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new_from_db(dog_row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE breed = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    self.new_from_db(dog_row)
  end

  def self.find_or_create_by(attributes)
    @@all.each { |dog|
      if dog.name == attributes[:name]
        if dog.breed == attributes[:breed]
          return dog
        end
      end
    }
    self.create(attributes)
  end
end
