defmodule TodoServer do
  def start do
    spawn(fn ->
      Process.register(self(), :todo_server)
      loop(TodoList.new)
    end)
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  defp loop(todo_list) do
    new_list= receive do
      message ->
        process_message(todo_list, message)
    end

    loop(new_list)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end
end

defmodule TodoList do
  def new do
    Map.new()
  end

  def add_entry(todo_list, entry) do
    Map.update(
      todo_list,
      entry.date,
      [entry.title],
      &[entry.title | &1]
    )
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end
